defmodule Hash do

    @moduledoc """
    Hash a given key using Cryptographic hash function SHA256.
    """

    def generateHash(key) do
        :crypto.hash(:sha256, key) |> Base.encode16 
    end
end