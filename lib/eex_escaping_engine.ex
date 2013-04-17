defmodule EEx.EscapingEngine do
  @moduledoc """
  An engine that allows a developer to access
  assigns using `@` as syntax. The string will be escaped so that
  it can be used in HTML.
  
  To ouput the raw string, use `@@`
  """

  @doc false

      @behavior EEx.Engine
      
      def handle_text(buffer, text) do
        EEx.Engine.handle_text(buffer, text)
      end

      def handle_expr(buffer, mark, expr) do
        EEx.Engine.handle_expr(buffer, mark, transform(expr))
      end
      
      
      defp transform({ :@, _line, [{ name, _, atom }] }) when is_atom(name) and is_atom(atom) do
        quote(do: escape(Keyword.get var!(_assigns), unquote(name)))
      end
      
      defp transform({ :unsafe!, _line, [{ name, _, atom }] }) when is_atom(name) and is_atom(atom) do
        quote(do: Keyword.get var!(_assigns), unquote(name))
      end
      
      defp transform(other) do
        other
      end

end

defmodule Eex.EscapingEngine.Functions do
  defmacro __using__(_) do
    quote do
      def escape(s) when is_binary(s), do: escape(s, <<>>)
      def escape(s) when is_list(s), do: escape(list_to_binary(s), <<>>)
      def escape(s), do: s
      def escape(<<?<, rest :: binary>>,acc), do: escape(rest, <<acc ::binary,"&lt;">>)
      def escape(<<?>, rest :: binary>>,acc), do: escape(rest, <<acc ::binary,"&gt;">>)
      def escape(<<?&, rest :: binary>>,acc), do: escape(rest, <<acc ::binary,"&amp;">>)
      def escape(<<34, rest :: binary>>,acc), do: escape(rest, <<acc ::binary,"&quot;">>)
      def escape(<<39, rest :: binary>>,acc), do: escape(rest, <<acc ::binary,"&#039;">>)
      def escape(<<c, rest :: binary>>,acc), do: escape(rest, <<acc ::binary, c>>)
      def escape(<<>>,acc), do: acc
    end
  end
end