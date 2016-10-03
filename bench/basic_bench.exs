defmodule BasicBench do
  use Benchfella
  alias Liquid.{Template, Tag}

  @list Enum.to_list(1..1000)
  @short_list Enum.to_list(1..100)

  defmodule MyFilter do
    def meaning_of_life(_), do: 42
  end

  defmodule MyFilterTwo do
    def meaning_of_life(_), do: 40
    def plus_one(input) when is_binary(input) do
      input |> Integer.parse |> elem(0) |> plus_one
    end
    def plus_one(input) when is_number(input), do: input + 1
    def not_meaning_of_life(_), do: 2
  end

  defmodule MinusOneTag do
    def parse(%Tag{}=tag, %Template{}=context) do
      {tag, context}
    end

    def render(_input, tag, context) do
      number = tag.markup |> Integer.parse |> elem(0)
      {["#{number - 1}"], context}
    end
  end

  defmodule BenchFileSystem do
      def read_template_file(_root, _template_path, _context) do
        File.read "bench/dummy-template.liquid"
      end
  end

  setup_all do
    Application.put_env(:liquid, :extra_filter_modules, [MyFilter, MyFilterTwo])
    Liquid.start
    Liquid.Registers.register("minus_one", MinusOneTag, Tag)
    {:ok, nil}
  end

  bench "Loop list" do
    assigns = %{"array" => @list}
    markup = "{%for item in array %}{{item}}{%endfor%}"
    t = Template.parse(markup)
    { :ok, _rendered, _ } = Template.render(t, assigns)
  end

  bench "Loop custom filters and tags list" do
    assigns = %{"array" => @list}
    markup = "{%for item in array %}{%minus_one 3%}{{item | plus_one }}{%endfor%}"
    t = Template.parse(markup)
    { :ok, _rendered, _ } = Template.render(t, assigns)
  end

  bench "load file" do
    f = BenchFileSystem.read_template_file("root","file",%{})
  end

  bench "dummy-world template rendering" do
    markup = "{% include 'dummy-template' %}"
    context = %Liquid.Context{assigns: %{"array" => @short_list}, registers: %{file_system: { BenchFileSystem, "" }}}
    markup |> Template.parse |> Template.render(context) |> elem(1)
  end
end
