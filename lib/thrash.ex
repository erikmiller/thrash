defmodule Thrash do
  defmodule Type do
    def id(:i32), do: 8
    def id(:string), do: 11

    defmacro i32,    do: quote do: 8
    defmacro string, do: quote do: 11
  end

  defmodule BinaryAcceleratedProtocol do
    require Thrash.Type

    def deserializer_name(field) do
      String.to_atom("deserialize_" <> Atom.to_string(field))
    end

    defmacro generate_deserializer(thrift_def) do
      [quote do
        def deserialize(str, template \\ __struct__) do
          deserialize_field(0, str, template)
        end
      end] ++ generate_field_deserializers(thrift_def)
    end

    def generate_field_deserializers(thrift_def) do
      Enum.with_index(thrift_def ++ [final: nil])
      |> Enum.map(fn({{k, v}, ix}) ->
        type = v
        varname = k
        deserializer(type, varname, ix)
      end)
    end

    def deserializer(:i32, fieldname, ix) do
      quote do
        def deserialize_field(unquote(ix),
                              <<unquote(Type.id(:i32)), unquote(ix + 1) :: 16-unsigned, value :: 32-signed, rest :: binary>>,
                              acc) do
          deserialize_field(unquote(ix) + 1, rest, Map.put(acc, unquote(fieldname), value))
        end
      end
    end
    def deserializer(:string, fieldname, ix) do
      quote do
        def deserialize_field(unquote(ix),
                              << unquote(Type.id(:string)), unquote(ix + 1) :: 16-unsigned, len :: 32-unsigned, value :: size(len)-binary, 0, rest :: binary>>,
                              acc) do
          deserialize_field(unquote(ix) + 1, rest, Map.put(acc, unquote(fieldname), value))
        end
      end
    end
    def deserializer(nil, :final, ix) do
      quote do
        def deserialize_field(unquote(ix), _, acc), do: acc
      end
    end
  end
end
