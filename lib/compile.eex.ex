defmodule Mix.Tasks.Compile.Eex do
  use Mix.Task
  
  @hidden true
  @shortdoc "Compile Eex source files"

  @moduledoc """
  A task to compile Eex source files.
  
  ## Command line options

   * `--force` - forces compilation regardless of module times;

  ## Configuration

  * `:eexc_paths` - directories to find source files.
    Defaults to `["templates"]`, can be configured as:

        [eexc_paths: ["templates", "other"]]

   * `:eexc_exts` - extensions to compile

         [eexc_exts: [:html]]
         
  """
  def run(args) do
    
    { opts, _ } = OptionParser.parse(args, aliases: [], switches: [force: :boolean])

    project       = Mix.project
    compile_path  = project[:compile_path]
    compile_exts  = project[:eexc_exts] || [:html]
    eexc_paths    = project[:eexc_paths] || ["templates"]
    
    File.mkdir_p! compile_path
    
    to_compile = Mix.Utils.extract_files(eexc_paths, compile_exts)
    stale = Enum.filter to_compile, fn(file) ->
      module_file = Path.join(compile_path, beam_file_name(file))
      last_modified(file) > last_modified(module_file) 
    end
    
    cond do
      opts[:force] -> compile_files(to_compile, compile_path)
      stale != []  -> compile_files(stale, compile_path)
      true         -> :noop
    end
    
  end
  
  # stolen from https://github.com/elixir-lang/elixir/blob/master/lib/mix/lib/mix/utils.ex
  defp last_modified(path) do
    case File.stat(path) do
      { :ok, File.Stat[mtime: mtime] } -> mtime
      { :error, _ } -> { { 1970, 1, 1 }, { 0, 0, 0 } }
    end
  end
  
  defp compile_files(files, to) do
    Code.delete_path to
    Enum.each files, fn(file) ->
      module = make_module(module_name(file), file)
      [{module_name, code}] = Code.compile_string(module, file)
      path = Path.join(to, module_name ) <> ".beam"
      File.write! path, code
      Mix.shell.info "Compiled #{file}"
    end
    Code.prepend_path to
  end
  
  defp module_name(file), do: 
    Enum.map_join Path.split(Path.rootname(file)), ".", String.capitalize(&1)
    
  defp beam_file_name(file), do:
    "Elixir-" <> (Enum.map_join Path.split(Path.rootname(file)), "-", String.capitalize(&1)) <> ".beam"
  
  defp make_module(module_name, file) do
    """
    defmodule #{module_name} do
      require EEx
      require EEx.SmartEngine
      EEx.function_from_file :def, :render, "#{file}", [:assigns]
    end
    """
  end
  
end
