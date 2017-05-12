module Hydna

using HTTPClient.HTTPC

export
    SendOptions,
    EmitOptions,
    send,
    emit

type SendOptions
    blocking::Bool 
    timeout::Float64
    priority::Int8    
    SendOptions(; blocking=true,
                  timeout=0.0,
                  priority=0)=new(blocking, timeout, priority)
end


type EmitOptions
    blocking::Bool 
    timeout::Float64
    EmitOptions(; blocking=true, timeout=0.0)=new(blocking, timeout)
end


type Result
    success::Bool
    data::String
    Result() = new(true, "")
end


function send(url::String, data, options::SendOptions=SendOptions())

    if options.priority < 0 || options.priority > 5
        error ("Bad priority")
    end

    validate_payload(data)

    if options.blocking
        req_headers = [("X-Priority", string(options.priority))]

        req_options = RequestOptions(blocking=options.blocking,
                                     request_timeout=options.timeout,
                                     headers=req_headers)

        response = HTTPC.post(url, data, req_options)
        return get_result(response)
    end

    return remotecall(myid(), send, url, data, copy_options(options))
end


function emit(url::String, data, options::EmitOptions=EmitOptions())

    validate_payload(data)

    if options.blocking
        req_headers = [("X-Emit", "yes")]

        req_options = RequestOptions(headers=req_headers)

        response = HTTPC.post(url, data, req_options)
        return get_result(response);
    end

    return remotecall(myid(), emit, url, data, copy_options(options))
end


function copy_options(options)
    result = deepcopy(options)
    result.blocking = true
    return result
end


function get_result(response)
    result = Result()

    if (response.http_code == 200)
    println(response.body)
        result.data = takebuf_string(response.body)
        return result
    else
        result.success = false
        result.data = takebuf_string(response.body)
    end

    return result
end


function validate_payload(data)
    if isa(data, String)
        if is_valid_utf8(data) == false
            error ("Invalid UTF8 string")
        end

        if sizeof(data) > 65530
            error ("Payload is to big")
        end

    elseif isa(data, IO)
        seekend(data)
        len = position(data)
        seekstart(data)

        if len > 65530
            error ("Payload is to big")
        end
    else
        error ("Invalid payload")
    end
end


end