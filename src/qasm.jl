# IBM Qobj IR
module QASM

using ..IBMQClient: Maybe

struct Program
    id::String
    inst::Vector{Any}
end

end
