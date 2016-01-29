defmodule TacoType do
  use Thrash.Enumerated, {"src/gen-erl/thrash_test_types.hrl",
                          "THRASH_TEST_TACOTYPE"}
end

defmodule SubStruct do
  defstruct(Thrash.read_struct_def(:thrash_test_types, :'SubStruct'))

  require Thrash.Protocol.Binary
  Thrash.Protocol.Binary.generate(:thrash_test_types, :'SubStruct')
end

defmodule SimpleStruct do
  defstruct(Thrash.read_struct_def(:thrash_test_types,
                                   :'SimpleStruct',
                                   taco_pref: :chicken))

  require Thrash.Protocol.Binary
  Thrash.Protocol.Binary.generate(:thrash_test_types,
                                  :'SimpleStruct',
                                  taco_pref: {:enum, TacoType})
end