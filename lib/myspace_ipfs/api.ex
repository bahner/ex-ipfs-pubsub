defmodule MyspaceIpfs.Api do
  @moduledoc """
  IPFS (the InterPlanetary File Syste
  new hypermedia distribution protocol, addressed by
  content and identities. IPFS enables the creation of
  completely distributed applications. It aims to make the web
  faster, safer, and more open.


  IPFS is a distributed file system that seeks to connect
  all computing devices with the same system of files. In some
  ways, this is similar to the original aims of the Web, but IPFS
  is actually more similar to a single bittorrent swarm exchanging
  git objects.

  Forked from https://github.com/tensor-programming/Elixir-Ipfs-Api

  Based on https://github.com/tableturn/ipfs/blob/master/lib/ipfs.ex
  """
  use Tesla, docs: false
  import MyspaceIpfs.Utils
  alias MyspaceIpfs.ApiError
  require Logger

  # Types
  @typep path :: MyspaceIpfs.path()
  @typep opts :: MyspaceIpfs.opts()
  @typep multipart :: Tesla.Multipart.t()

  @typedoc """
  The response from the API. It can be a binary, a map, a list or an error.
  """
  @type api_response :: binary | map | list | api_error
  @typedoc """
  The error response from the API after we have handle it.
  """
  @type api_error :: {:error, MyspaceIpfs.ApiError.t()} | {:error, Tesla.Env.t()} | {:error, atom}

  @api_url Application.compile_env(:myspace_ipfs, :api_url, "http://localhost:5001/api/v0/")

  # Middleware
  plug(Tesla.Middleware.BaseUrl, @api_url)
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Logger)

  @doc """
  High level function allowing to perform POST requests to the node.
  A `path` has to be provided, along with an optional list of `opts` that are
  dependent on the endpoint that will get hit.
  NB! This is not a GET request, but a POST request. IPFS uses POST requests.
  """
  @spec post_query(path, opts) :: api_response
  def post_query(path, opts \\ []) do
    post(path, <<>>, opts)
    |> handle_response()
  end

  @doc """
  High level function allowing to send data to the node.
  A `path` has to be specified along with the `data` to be sent. Also, a list
  of `opts` can be optionally sent.

  Data is sent first, so that it can easily be part of a pipe.
  """
  @spec post_multipart(multipart, binary, list) :: api_response
  def post_multipart(mp, path, opts \\ []) do
    post(path, mp, opts)
    |> handle_response()
  end

  @spec handle_response({:ok, Tesla.Env.t()}) :: api_response
  def handle_response(response) do
    # Handles the response from the node. It returns the body of the response
    # if the status code is 200, otherwise it returns an error tuple.
    # ## Status codes that are handled
    # https://docs.ipfs.tech/reference/kubo/rpc/#http-status-codes
    #   - 200 - The request was processed or is being processed (streaming)
    #   - 500 - RPC Endpoint returned an error
    #   - 400 - Malformed RPC, argument type error, etc.
    #   - 403 - RPC call forbidden
    #   - 404 - RPC endpoint does not exist
    #   - 405 - RPC endpoint exists but method is not allowed
    # Removing categorised status codes from the case statement.
    # This is of no use to the user, and not for the code either, as far as I can think of.
    # It just gives us more to match against, which is needlessly complex.

    case response do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        body

      {:ok, %Tesla.Env{status: 500, body: body}} ->
        ApiError.handle_api_error(body)

      {:ok, %Tesla.Env{status: 400}} ->
        {:error, unokify(response)}

      {:ok, %Tesla.Env{status: 403}} ->
        {:error, unokify(response)}

      {:ok, %Tesla.Env{status: 404}} ->
        {:error, unokify(response)}

      {:ok, %Tesla.Env{status: 405}} ->
        {:error, unokify(response)}

      {:error, {Tesla.Middleware.JSON, :decode, json_error}} ->
        extract_data_from_json_error(json_error.data)

      {:error, :timeout} ->
        {:error, :timeout}
    end
  end
end
