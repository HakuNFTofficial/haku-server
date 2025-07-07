defmodule HakuServer.Contract do
  use Ethers.Contract,
    abi_file: Path.join([__DIR__, "abi", "abi.json"]),
    default_address: System.get_env("CONTRACT_ADDRESS")
end
