# Hydna Julia Client Library

This first version of our client library for Julia implements support for the
Hydna Push API. Future versions will include support for the full set of
features.

More info: https://www.hydna.com/

## Usage

The exported APIs from module Hydna are:

    using Hydna

    # send a message
    result = Hydna.send('public.hydna.net/julia-test', 'hello world')
    @test result.success

    # send message with priority 3
    result = Hydna.send('public.hydna.net/julia-test',
                        'hello world',
                        SendOptions(priority=3))
    @test result.success

    # send a non-blocking message
    ref = Hydna.send('public.hydna.net/julia-test',
                     'hello world',
                     SendOptions(blocking=false))
    result = fetch(ref)
    @test result.success

    # emit a signal
    result = Hydna.emit('public.hydna.net/julia-test', 'hello world signal')
    @test result.success

    # emit a non-blocking signal
    ref = Hydna.emit('public.hydna.net/julia-test',
                     'hello world',
                     EmitOptions(blocking=false))
    result = fetch(ref)
    @test result.success
