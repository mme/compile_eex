defmodule Mix.Tasks.Compile.Eex do
  use Mix.Task
  
  @hidden true
  @shortdoc "Compile Eex source files"

  @moduledoc """
  A task to compile Eex source files.

  ## Configuration

  * `:eexc_paths` - directories to find source files.
    Defaults to `["templates"]`, can be configured as:

        [eexc_paths: ["templates", "other"]]

   * `:eexc_exts` - extensions to compile

         [eexc_exts: [:html]]
         
  """
  def run(_args) do

    project       = Mix.project
    compile_path  = project[:compile_path]
    compile_exts  = project[:eexc_exts] || [:html]
    eexc_paths    = project[:eexc_paths] || ["templates"]

    to_compile = Mix.Utils.extract_files(eexc_paths, compile_exts)
    
    File.mkdir_p! compile_path
    compile_files to_compile, compile_path
  end
  
  defp compile_files(files, to) do
    Code.delete_path to
    Enum.each files, fn(file) ->
      module = make_module(make_module_name(file), file)
      [{module_name, code}] = Code.compile_string(module, file)
      path = Path.join(to, module_name ) <> ".beam"
      File.write! path, code
      Mix.shell.info "Compiled #{file}"
    end
    Code.prepend_path to
  end
  
  defp make_module_name(file), do: 
    Enum.map_join Path.split(Path.rootname(file)), ".", String.capitalize(&1)
  
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
