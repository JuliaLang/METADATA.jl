__precompile__()

module Zabbix

# Imports
using Requests
using JSON

"""
# Zabbix API

#### create the zabbix object

julia>z = ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php","USERNAME","PASSWORD", true)
ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php", "USERNAME", "PASSWORD", true, 0, Dict("Content-Type"=>"application/json-rpc"), "2.0")

### Note:

Here the verbosity is set to true by default. You may wish to set up by passing false instead of true.
"""
type ZabbixAPI

    # To be supplied fields
    server_url::String
    username::String
    password::String

    # By default set, but can be changed while instantiating
    verbose::Bool

    # By default set
    id::Int64
    headers::Dict
    jsonrpc::String

    # Inner constructor
    ZabbixAPI(server_url,username,password,id=1,verbose=true,headers=Dict("Content-Type"=>"application/json-rpc"),
    jsonrpc="2.0") = new(server_url,username,password,id,verbose,headers,jsonrpc)
end


"""
# Gets the apiinfo.version data from zabbix server

#### create the zabbix object

julia>z = ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php","USERNAME","PASSWORD", true)


#### get the api version

julia>api_version(z)

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

"3.2.11"

"""
function api_version(z::ZabbixAPI)
    verbose = z.verbose

    # contruct data
    dict_data = Dict("jsonrpc"=>z.jsonrpc,"id"=>z.id,"method"=>"apiinfo.version","params"=>Dict())
    json_data = JSON.json(dict_data)

    # requests data from zabbix
    if verbose info("Hitting $(z.server_url) ...") end
    output = Requests.post(z.server_url,data=json_data,headers=z.headers)

    # return response
    JSON.parse(convert(String, output.data))["result"]
end



"""
# Gets the authentication token from zabbix server

#### create the zabbix object

julia>z = ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php","USERNAME","PASSWORD", true)


#### get the auth token

julia> auth_token(z)

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

"bc86891a1c6c9ef5d41d640eb258a81a"

"""
function auth_token(z::ZabbixAPI)
    verbose = z.verbose

    # construct data
    dict_data=Dict("jsonrpc"=>z.jsonrpc,"id"=>z.id,"method"=>"user.login",
            "params"=>Dict("user"=>z.username,"password"=>z.password))
    json_data = JSON.json(dict_data)

    # requests data from zabbix
    if verbose info("Hitting $(z.server_url) ...") end
    output = Requests.post(z.server_url,data=json_data,headers=z.headers)

    # return token
    JSON.parse(convert(String, output.data))["result"]

end



"""
# Gets all host for a user

#### create the zabbix object

julia>z = ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php","USERNAME","PASSWORD", false)


#### get all hosts for a user

julia>get_all_hosts(z)

INFO: Getting authentication token ... 

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

Dict{String,Any} with 3 entries:
  "id"      => 1
  "jsonrpc" => "2.0"
  "result"  => Any[Dict{String,Any}(Pair{String,Any}("host", "localhost"),Pair{…

"""
function get_all_hosts(z::ZabbixAPI)
    verbose = z.verbose

    # get token
    if verbose info("Getting authentication token ... ") end
    token = auth_token(z)

    # construct data
    dict_data = Dict("jsonrpc"=>z.jsonrpc,"id"=>z.id,"method"=>"host.get","auth"=>token,
                        "params"=>Dict("output"=>["hostid","host"],"selectInterfaces"=>["interfaceid","ip"]))
    json_data = JSON.json(dict_data)

    # requests data from zabbix
    if verbose info("Hitting $(z.server_url) ...") end
    output = Requests.post(z.server_url,data=json_data,headers=z.headers)

    # return token
    JSON.parse(convert(String, output.data))

end



"""
# Make request to the zabbix server

The make_request function requires you to pass methods(aka Zabbix methods like hosts.get etc) and params ie. parameters in a form of a Dict() object. A easy sample is given on Zabbix's official website
For references on various methods available in Zabbix,
head over to https://www.zabbix.com/documentation/2.2/manual/api/reference

#### create the zabbix object

julia>z = ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php","USERNAME","PASSWORD", true)

julia> Zabbix.make_request(z, "apiinfo.version", Dict())

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

"3.2.11"

#### create the zabbix method

julia> method = "host.get"

"host.get"


#### construct the params dict object

julia> params = Dict("output"=>"extend", "filter"=>Dict("host"=>["localhost"]))

Dict{String,Any} with 2 entries:
  "output" => "extend"
  "filter" => Dict("host"=>String["localhost"])

#### create the zabbix object

julia>z = ZabbixAPI("http://SERVER_URL/zabbix/api_jsonrpc.php","USERNAME","PASSWORD", true)

#### finally make request

julia> Zabbix.make_request(z, method, params)

INFO: Getting authentication token ... 

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

INFO: Updating request id for next API call ...

Dict{String,Any} with 3 entries:
  "id"      => 1
  "jsonrpc" => "2.0"
  "result"  => Any[Dict{String,Any}(Pair{String,Any}("lastaccess", "0"),Pair{String,Any}("ipmi_privilege", "2"),Pair{String,Any}("ipmi_error…

#### display all entries for a host

julia> Zabbix.make_request(z, method, params)["result"][1]

INFO: Getting authentication token ... 

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

INFO: Updating request id for next API call ...

Dict{String,Any} with 39 entries:
  "lastaccess"         => "0"
  "ipmi_privilege"     => "2"
  "ipmi_errors_from"   => "0"
  "snmp_available"     => "0"
  "templateid"         => "0"
  "disable_until"      => "0"
  "jmx_available"      => "0"
  "maintenance_from"   => "0"
  "tls_psk_identity"   => ""
  "available"          => "1"
  "ipmi_password"      => ""
  "tls_accept"         => "1"
  "name"               => "localhost"
  "tls_issuer"         => ""
  "status"             => "0"
  "maintenance_status" => "0"
  "hostid"             => "10084"
  "tls_connect"        => "1"
  "ipmi_available"     => "0"
  "description"        => ""
  "errors_from"        => "0"
  "maintenance_type"   => "0"
  "error"              => ""
  "ipmi_username"      => ""
  "snmp_disable_until" => "0"
  "snmp_error"         => ""
  "tls_subject"        => ""
  "maintenanceid"      => "0"
  "host"               => "localhost"
  "jmx_error"          => ""
  "ipmi_disable_until" => "0"
  "snmp_errors_from"   => "0"
  ⋮                    => ⋮


#### get the host id of the zabbix host

julia> Zabbix.make_request(z, method, params)["result"][1]["hostid"]

INFO: Getting authentication token ... 

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

INFO: Hitting http://SERVER_URL/zabbix/api_jsonrpc.php ...

INFO: Updating request id for next API call ...

"10084"

"""
function make_request(z::ZabbixAPI, method::String, params=Dict())
    verbose = z.verbose
    
    if method == "apiinfo.version" && params == Dict()
        return api_version(z)
    else
        # get token
        if verbose info("Getting authentication token ... ") end
        token = auth_token(z)
        
        # construct data
        dict_data = Dict("jsonrpc"=>z.jsonrpc,"id"=>z.id,"method"=>method,"auth"=>token,"params"=>params)
        json_data = JSON.json(dict_data)

        # requests data from zabbix
        if verbose info("Hitting $(z.server_url) ...") end
        output = Requests.post(z.server_url,data=json_data,headers=z.headers)

        # increment the id for further calls
        if verbose info("Updating request id for next API call ...") end
        setfield!(z,:id, z.id+1)
        
        # return token
        JSON.parse(convert(String, output.data))
    end
end

# Exports
export ZabbixAPI, api_version, get_all_hosts, make_request

end
