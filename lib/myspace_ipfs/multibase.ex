defmodule MyspaceIPFS.Multibase do
  @moduledoc """
  MyspaceIPFS.Multibase is where the multibase commands of the IPFS API reside.
  """

  import MyspaceIPFS.Api
  import MyspaceIPFS.Utils
  alias Tesla.Multipart
  alias MyspaceIPFS.Multibase.Codec

  @typep okresult :: MyspaceIPFS.okresult()
  @typep opts :: MyspaceIPFS.opts()

  # Fixme add _file variants.
  @doc """
  Decode a multibase encoded string.

  ## Parameters
    `data` - File to decode.
  """
  @spec decode(binary) :: okresult
  def decode(data) do
    multipart_content(data)
    |> post_multipart("/multibase/decode")
    |> handle_api_response()
    |> okify()
  end

  @doc """
  Encode a string to a multibase encoded string.

  ## Parameters
    `data` - File to encode.

  ## Options
    `b` - Multibase encoding to use.
  """
  @spec encode(binary, opts) :: okresult
  def encode(data, opts \\ []) do
    Multipart.new()
    |> Multipart.add_file_content(data, "file")
    |> post_multipart("/multibase/encode", query: opts)
    |> handle_api_response()
    |> okify()
  end

  @doc """
  List available multibase encodings.

  ## Options
    prefix - Only list encodings with the given prefix.
    numeric - Only list encodings with the given numeric code.
  """
  @spec list(opts) :: okresult
  def list(opts \\ []) do
    post_query("/multibase/list", query: opts)
    |> handle_api_response()
    |> filter_empties()
    |> snake_atomize()
    |> Enum.map(fn x -> Codec.gen_multibase_codec(x) end)
    |> okify()
  end

  @doc """
  Transcode a multibase encoded string.

  ## Parameters
    `data` - Data to transcode.

  ## Options
    `b` - Multibase encoding to use
  """
  @spec transcode(binary, opts) :: okresult
  def transcode(data, opts \\ []) do
    multipart_content(data)
    |> post_multipart("/multibase/transcode", query: opts)
    |> handle_api_response()
    |> okify()
  end
end
