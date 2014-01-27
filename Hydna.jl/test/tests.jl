using Hydna
using Base.Test

r=Hydna.send("testing.hydna.net", "test")
@test r.success
println("Test send-ascii passed")

r=Hydna.send("testing.hydna.net/test-token?token", "test")
@test r.success
println("Test token passed")

r=Hydna.send("testing.hydna.net", IOBuffer("test"))
@test r.success
println("Test send-binary passed")

try
  Hydna.send("testing.hydna.net", "test", SendOptions(priority=7))
catch e
  @test string(e) == "ErrorException(\"Bad priority\")"
  println("Test wrong-priority passed")
end


r=Hydna.send("testing.hydna.net/open-deny", "test")
@test r.success == false && r.data == "DENIED"
println("Test open-deny passed")


rr=Hydna.send("testing.hydna.net", "test", SendOptions(blocking=false))
r = fetch(rr)
@test r.success
println("Test send-nonblocking, passed");

r=Hydna.emit("testing.hydna.net", "test")
@test r.success
println("Test emit-ascii passed")