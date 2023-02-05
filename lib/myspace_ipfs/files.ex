defmodule MyspaceIPFS.Files do
  @moduledoc """
  MyspaceIPFS.Files is where the files commands of the IPFS API reside.
  """
  import MyspaceIPFS.Api
  import MyspaceIPFS.Utils

  @typedoc """
  List of entries in a directory. Each entry is a Hash.
  """
  @type entries :: [MyspaceIPFS.FilesEntry.t()]

  @typedoc """
  A FileEntry struct.
  """
  @type entry :: %MyspaceIPFS.FilesEntry{
          hash: MyspaceIPFS.hash(),
          name: binary(),
          size: non_neg_integer(),
          type: binary()
        }

  @typedoc """
  A FileStat struct.
  """
  @type stat :: %MyspaceIPFS.FilesStat{
          blocks: non_neg_integer(),
          cumulative_size: non_neg_integer(),
          hash: MyspaceIPFS.hash(),
          size: non_neg_integer(),
          type: binary()
        }
  @doc """
  Copy files into mfs.

  ## Parameters
  source: The source file to copy.
  dest: The destination path for the file to be copied to.

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-cp
  ```
  [
    parents: <bool>, # Make parent directories as needed.
  ]
  ```
  """
  # FIXME: verify return type
  @spec cp(Path.t(), Path.t(), list) :: :ok | MyspaceIPFS.Api.error_response()
  def cp(source, dest, opts \\ []) do
    post_query("/files/cp?arg=" <> source <> "&arg=" <> dest, query: opts)
    |> handle_files_response()
  end

  @doc """
  Change the CID version or hash function of a path's root node.

  ## Parameters
  path: The path to change the CID for, if in doubt use "/"

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-chcid
  ```
  [
    cid-version: <int>, # CID version. (experimental)
    hash: <string>, # Hash function to use. Implies CID version 1 if used. (experimental)
  ]
  ```
  """
  # FIXME: verify return type
  @spec chcid(Path.t(), list) :: {:ok, any} | MyspaceIPFS.Api.error_response()
  def chcid(path, opts \\ []) do
    post_query("/files/chcid?arg=" <> path, query: opts)
    |> okify()
  end

  @doc """
  Get the filepaths of all files in a directory.

  This is a convenience function, if you just want the filenames from the ls command.
  Use it in a pipeline like this:

  ```
  MyspaceIPFS.Files.ls("/some/path")
  |> MyspaceIPFS.Files.extract_entries_names()
  ```
  """
  @spec extract_entries_names(%{:entries => any}) :: [binary()]
  def extract_entries_names(entries) when is_map(entries) do
    Enum.map(entries.entries, fn entry ->
      entry.name
    end)
  end

  def extract_entries_names({:error, data}), do: {:error, data}

  @doc """
  Flush a given path's data to disk.

  ## Parameters
  https://docs.ipfs.io/reference/http/api/#api-v0-files-flush
  `path` - The path to flush. If not specified, the entire repo will be flushed.
  """
  # FIXME: verify return type
  @spec flush() :: {:ok, any} | MyspaceIPFS.Api.error_response()
  def flush() do
    post_query("/files/flush")
    |> okify()
  end

  @spec flush(Path.t()) :: {:ok, any} | MyspaceIPFS.Api.error_response()
  def flush(path) do
    post_query("/files/flush?arg=" <> path)
    |> okify()
  end

  @doc """
  List directories in the local mutable namespace.

  ## Parameters
  `path`| - The path to list. If in doubt, use "/".

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-ls
  ```
  [
    l: <bool>, # Use long listing format.
    U: <bool>, # Do not sort; list entries in directory order.
  ]
  ```
  """
  @spec ls!(Path.t(), list) :: entries() | MyspaceIPFS.Api.error_response()
  def ls!(path, opts \\ []) do
    post_query("/files/ls?arg=" <> path, query: opts)
    |> MyspaceIPFS.FilesEntries.new()
  end

  @doc """
  List directories in the local mutable namespace.
  https://docs.ipfs.io/reference/http/api/#api-v0-files-ls

  This command only returns the filepaths of the files in the directory.

  ## Parameters
  `path`| - The path to list. If in doubt, use "/".

  ## Options
  ```
  [
    l: <bool>, # Use long listing format.
    U: <bool>, # Do not sort; list entries in directory order.
  ]
  ```
  """
  @spec ls(Path.t(), list) :: {:ok, list} | MyspaceIPFS.Api.error_response()
  def ls(path, opts \\ []) do
    ls!(path, opts)
    |> okify()
  end

  @doc """
  Make directories.

  ## Parameters
  `path` - The path to make directories at.

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-mkdir
  ```
  [
    `parents` - <bool>, # No error if existing, make parent directories as needed.
    `hash` - <string>, # Hash function to use. Implies CID version 1 if used. (experimental)
    `cid-version` - <int>, # CID version. (experimental)
  ]
  ```
  """

  @spec mkdir(Path.t(), list) :: :ok | MyspaceIPFS.Api.error_response()
  def mkdir(path, opts \\ []) do
    post_query("/files/mkdir?arg=" <> path, query: opts)
    |> handle_files_response()
  end

  @doc """
  Move files.

  ## Parameters
  `source` - The source file to move.
  `dest` - The destination path for the file to be moved to.
  """
  @spec mv(Path.t(), Path.t()) :: :ok | MyspaceIPFS.Api.error_response()
  def mv(source, dest) do
    post_query("/files/mv?arg=" <> source <> "&arg=" <> dest)
    |> handle_files_response()
  end

  @doc """
  Read a file in a given mfs.

  ## Parameters
  `path` - The path to the file to be read.

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-read
  ```
  [
    offset: <int>, # Byte offset to begin reading from.
    count: <int>, # Maximum number of bytes to read.
  ]
  ```
  """
  @spec read!(Path.t(), list) :: any | MyspaceIPFS.Api.error_response()
  def read!(path, opts \\ []) do
    post_query("/files/read?arg=" <> path, query: opts)
  end

  @spec read(Path.t(), list) :: {:ok, any} | MyspaceIPFS.Api.error_response()
  def read(path, opts \\ []) do
    read!(path, opts)
    |> okify()
  end

  @doc """
  Remove a file from mfs.

  ## Parameters
  `path` - The path to the file to be removed.

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-rm
  ```
  [
    r|recursive: <bool>, # Recursively remove directories.
    force: <bool>, # Forcibly remove target at path; implies recursive for directories.
  ]
  ```
  """
  @spec rm(Path.t(), list) :: :ok | {:error, binary}
  def rm(path, opts \\ []) do
    post_query("/files/rm?arg=" <> path, query: opts)
    |> handle_files_response()
  end

  @doc """
  Get file status.

  ## Parameters
  `path` - The path to the file to stat.

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-stat
  ```
  [
    format: <string>, # Format to print out.
                      Allowed tokens:
                      <hash> <size> <cumulsize> <type> <childs>
    hash: <bool>, # Compute the hash of the file.
    size: <bool>, # Compute the size of the file.
    with-local: <bool>, # Compute the size of the file including the local repo.
  ]
  ```
  """
  @spec stat(Path.t(), list) :: {:ok, any} | MyspaceIPFS.Api.error_response()
  def stat(path, opts \\ []) do
    post_query("/files/stat?arg=" <> path, query: opts)
    |> MyspaceIPFS.FilesStat.new()
    |> okify()
  end

  @doc """
  Write to a mutable file in a given filesystem.

  ## Parameters
  `path` - The path to write to.
  `data` - The data to write.

  ## Options
  https://docs.ipfs.io/reference/http/api/#api-v0-files-write
  ```
  [
    create: <bool>, # Create the file if it does not exist.
    truncate: <bool>, # Truncate the file to size zero before writing.
    offset: <int>, # Byte offset to begin writing at.
    count: <int>, # Maximum number of bytes to write.
    raw-leaves: <bool>, # Use raw blocks for newly created leaf nodes. (experimental)
    cid-version: <int>, # CID version. (experimental)
    hash: <string>, # Hash function to use. Implies CID version 1 if used. (experimental)
    parents: <bool>, # No error if existing, make parent directories as needed.
  ]
  ```
  """
  @spec write!(Path.t(), Path.t(), list) :: :ok | MyspaceIPFS.Api.error_response()
  def write!(data, path, opts \\ []) do
    mp = multipart_content(data)

    post_multipart(mp, "/files/write?arg=" <> path, query: opts)
    |> handle_files_response()
  end

  @spec write(Path.t(), Path.t(), list) :: {:ok, any} | MyspaceIPFS.Api.error_response()
  def write(data, path, opts \\ []) do
    write!(data, path, opts)
    |> okify()
  end

  # Files API sometimes just sends an empty string as a response.
  # That means OK.
  defp handle_files_response(response) do
    case response do
      "" -> :ok
      _ -> response
    end
  end
end
