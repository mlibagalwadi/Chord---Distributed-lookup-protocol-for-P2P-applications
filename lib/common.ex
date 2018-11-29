
defmodule Common do

  @doc """
  Initiates the node with some default values as mentioned below:
  * Hashed PID
  * Hashed PID of it's successor
  * List of Fingers of the node in the Chord Ring
  * List of Keys stored
  * Number of request a node has to send yet
  """
  def init(:ok) do
      {:ok, {'', '', [], [], 0}}
  end

  @doc """
  Spawns a new Genserver process and returns the PID
  ## Example
      iex> Chord.start_node()
      Output:
      #PID<0.122.0>
  """
  def start_node() do
      {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
      pid
  end

  @doc """
  Updates the successor of the node with PID <pid>
  """
  def updateSuccesorState(pid, succesor) do
      GenServer.call(pid, {:UpdateSuccesorState,succesor})
  end

  @doc false
  def handle_call({:UpdateSuccesorState,succesor}, _from, state) do
      {a,b,c,d,e} = state
      state={a,succesor,c,d,e}
      {:reply,b, state}
  end

  @doc """
  Updates the number of Requests the node with PID <pid> can make.
  """
  def updateRequestState(pid, request, totalCount, numNodes) do
      # IO.inspect pid
      GenServer.call(pid, {:UpdateRequestState, request, totalCount, numNodes})
  end

  @doc false
  def handle_call({:UpdateRequestState, request, totalCount, numNodes}, _from, state) do
      {a,b,c,d,e} = state
      state={a,b,c,d,request}
      if request <= 0 do
          count = :ets.update_counter(:table, "globalCount", {2,1})
          # IO.puts "Found key number #{count}"
          totCount = base(totalCount,numNodes)
          # IO.inspect b
          if count >= totalCount  do

              # IO.puts "totalNumHops: #{:ets.update_counter(:table, "globalHopsCount", {2,0})}"

              # IO.puts "numNodes: #{numNodes}"
              # IO.puts "divCount: #{divCount}"

              result = round :math.ceil (:ets.update_counter(:table, "globalHopsCount", {2,0}))/totCount

              IO.puts "The average number of hops (node connections) that have to be traversed to deliver a message is #{result}"
              :timer.sleep(10)
              System.halt(1)
          end
      end
      {:reply,e, state}
  end

  @doc """
  Updates the keys stored in the node with PID <pid>
  """
  def updateKeyState(pid, key) do
       GenServer.call(pid, {:UpdateKeyState,key})
  end

  @doc false
  def handle_call({:UpdateKeyState,key}, _from, state) do
      {a,b,c,d,e} = state
      state={a,b,c, d ++ [key],e}
      # IO.inspect {a, d ++ [key]}
      {:reply,d ++ [key], state}
  end

  @doc """
  Updates the Finger Table of the node with PID <pid>
  """
  def updateFingersState(pid, finger) do
       GenServer.call(pid, {:UpdateFingersState,finger})
  end

  @doc false
  def handle_call({:UpdateFingersState,finger}, _from, state) do
      {a,b,c,d,e} = state
      state={a,b,c ++ [finger],d,e}
      # IO.puts "FFFFFFFF"
      # IO.inspect state
      {:reply,c ++ [finger], state}
  end

  @doc """
  Updates the PID and HashedPID of the node with PID <pid>
  """
  def updatePIDState(pid, hashPid) do
      GenServer.call(pid, {:UpdatePIDState,hashPid})
  end

  @doc false
  def handle_call({:UpdatePIDState,hashPid}, _from, state) do
      {a,b,c,d,e} = state
      state={hashPid,b,c,d,e}
      {:reply,a, state}
  end

  @doc """
  get the state of the current Node
  """
  def getState(pid) do
      GenServer.call(pid,{:GetState})
  end

  @doc false
  def handle_call({:GetState}, _from, state) do
      {a,b,c,d,e}=state
      # IO.inspect("b #{b}")
      {:reply,state, state}
  end

  def base(a,b) do
    :math.ceil(a * 3.5 * :math.pow(b,1/4))
  end



end
