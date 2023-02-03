defmodule MyspaceIpfs.Log do
  @moduledoc """
  MyspaceIpfs.Log is where the log commands of the IPFS API reside.
  """
  import MyspaceIpfs.Api
  import MyspaceIpfs.Utils

  @typep api_error :: MyspaceIpfs.Api.api_error()
  @typep name :: MyspaceIpfs.name()

  @doc """
  Change the logging level.

  ## Parameters
  https://docs.ipfs.io/reference/http/api/#api-v0-log-level
    `subsys` - Subsystem logging identifier.
    `level` - Logging level.
  """
  @spec level(name, name) :: {:ok, any} | api_error()
  def level(subsys \\ "all", level) do
    post_query("/log/level?arg=" <> subsys <> "&arg=" <> level)
    |> okify()
  end

  @doc """
  List the logging subsystems.
  """
  @spec ls() :: {:ok, any} | api_error()
  def ls do
    post_query("/log/ls")
    |> okify()
  end

  @doc """
  Read the event log.
  """
  @spec tail() :: {:ok, any} | api_error()
  def tail do
    post_query("/log/tail")
    |> okify()
  end
end
