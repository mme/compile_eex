defmodule Mix.Tasks.Compile.Eex do
  use Mix.Task
  
  @hidden true
  @shortdoc "Compile Eex source files"

  @moduledoc """
  A task to compile Eex source files.

  When this task runs, it will first check the mod times of
  all of the files to be compiled and if they haven't been
  changed since the last compilation, it will not compile
  them at all. If any one of them has changed, it compiles
  everything.

  For this reason, this task touches your `:compile_path`
  directory and sets the modification time to the current
  time and date at the end of each compilation. You can
  force compilation regardless of mod times by passing
  the `--force` option.

  Note it is important to recompile all files because
  often there are compilation time dependencies between
  the files (macros and etc). However, in some cases it
  is useful to compile just the changed files for quick
  development cycles, for such, a developer can pass
  the `--quick` otion.

  ## Command line options

  * `--force` - forces compilation regardless of module times;
  * `--quick`, `-q` - only compile files that changed;

  ## Configuration

  * `:eexc_paths` - directories to find source files.
    Defaults to `["views"]`, can be configured as:

        [eexc_paths: ["templates", "other"]]

  * `:eexc_options` - compilation options that applies
     to Elixir's compiler, they are: `:ignore_module_conflict`,
     `:docs` and `:debug_info`. By default, uses the same
     behaviour as Elixir

   * `:eexc_exts` - extensions to compile whenever there
     is a change:

         [eexc_exts: [:html]]

   * `:eexc_watch_exts` - extensions to watch in order to trigger
      a compilation:

         [eexc_watch_exts: [:html]]
         
  """
  def run(args) do
    { opts, _ } = OptionParser.parse(args, aliases: [q: :quick],
                    switches: [force: :boolean, quick: :boolean])

    project       = Mix.project
    compile_path  = project[:compile_path]
    compile_exts  = project[:eexc_exts] || [:html]
    watch_exts    = project[:eexc_watch_exts] || [:html]
    eexc_paths    = project[:eexc_paths] || ["templates"]

    to_compile = Mix.Utils.extract_files(eexc_paths, compile_exts)
    to_watch   = Mix.Project.config_files ++ Mix.Utils.extract_files(eexc_paths, watch_exts)
    stale      = Mix.Utils.extract_stale(to_watch, [compile_path])
    
    IO.inspect to_watch
    
    if opts[:force] or stale != [] do
      Mix.Utils.preserving_mtime(compile_path, fn ->
        File.mkdir_p! compile_path
        compile_files opts[:quick], project, compile_path, to_compile, stale
      end)
    
      :ok
    else
      :noop
    end
  end

  defp compile_files(true, project, compile_path, to_compile, stale) do
    IO.inspect to_compile
    opts = project[:elixirc_options] || []
    opts = Keyword.put(opts, :ignore_module_conflict, true)
    Code.compiler_options(opts)
    to_compile = lc f inlist to_compile, List.member?(stale, f), do: f
    compile_files to_compile, compile_path
  end
  
  defp compile_files(false, project, compile_path, to_compile, _stale) do
    Code.delete_path compile_path
    opts = project[:elixirc_options] || []
    Code.compiler_options(opts)
    compile_files to_compile, compile_path
    Code.prepend_path compile_path
  end
  
  defp compile_files(files, to) do
    Enum.each files, fn(file) ->
      module = make_module(make_module_name(file), file)
      [{module_name, code}] = Code.compile_string(module, file)
      path = Path.join(to, module_name ) <> ".beam"
      File.write! path, code
      Mix.shell.info "Compiled #{file}"
    end
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
