--[[=============================================================================
    c4_timer Class

    Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "c4_driver_declarations"
require "c4_object"

-- Set template version for this file
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.c4_timer = "2016.01.08"
end

c4_timer = inheritsFrom(nil)

function c4_timer:construct(name, interval, units, Callback, repeating, CallbackParam)
	self._name = name
	self._timerID = TimerLibGetNextTimerID()
	self._interval = interval
	self._units = units
	self._repeating = repeating or false
	self._Callback = Callback
	self._CallbackParam = CallbackParam or ""
	self._id = 0

	gTimerLibTimers[self._timerID] = self
	if (LOG ~= nil and type(LOG) == "table") then
		LogTrace("Created timer " .. self._name)
	end
end

function c4_timer:StartTimer(...)
	c4_timer:KillTimer()

	-- optional parameters (interval, units, repeating)
	if ... then
		local interval = select(1, ...)
		local units = select(2, ...)
		local repeating = select(3, ...)

		self._interval = interval or self._interval
		self._units = units or self._units
		self._repeating = repeating or self._repeating
	end

	if (tonumber(self._interval) > 0) then
		if (LOG ~= nil and type(LOG) == "table") then
			LogTrace("Starting Timer: " .. self._name)
		end

		self._id = C4:AddTimer(self._interval, self._units, self._repeating)
	end
end

function c4_timer:KillTimer()
	if (self._id) then
		self._id = C4:KillTimer(self._id)
	end
end

function c4_timer:TimerStarted()
	return (self._id ~= 0)
end

function c4_timer:TimerStopped()
	return (self._id == 0)
end

function c4_timer:GetTimerInterval()
	return (self._interval)
end

function TimerLibGetNextTimerID()
	gTimerLibTimerCurID = gTimerLibTimerCurID + 1
	return gTimerLibTimerCurID
end

function ON_DRIVER_EARLY_INIT.c4_timer()
	gTimerLibTimers = {}
	gTimerLibTimerCurID = 0
end

function ON_DRIVER_DESTROYED.c4_timer()
	-- Kill open timers
	for k,v in pairs(gTimerLibTimers) do
		v:KillTimer()
	end
end

--[[=============================================================================
    OnTimerExpired(idTimer)

    Description:
    Function called by Director when the specified Control4 timer expires.

    Parameters:
    idTimer(string) - Timer ID of expired timer.
===============================================================================]]
function OnTimerExpired(idTimer)
--[[ Do nothing here until we build out remote keystroke timers.
	for k,v in pairs(gTimerLibTimers) do
		if (idTimer == v._id) then
			if (v._Callback) then
				v._Callback(v._CallbackParam)
			end
		end
	end
]]
end

--[[=============================================================================
    CreateTimer(name, interval, units, callback, repeating, callbackParam)

    Description: 
    Creates a named timer with the given attributes

    Parameters:
    name(string)       - The name of the timer being created
    interval(int)      - The amount of the given time between calls to the
                         timers callback function
    units(string)      - The time of time interval used (e.g. SECONDS, MINUTES, ...)
    callback(string)   - The function to call when the timer expires
    repeating(bool)    - Parameter indicating whether the timer should be
                         called repeatedly until cancelled
    callbackParam(...) - Parameters to be passed to the callback function

    Returns:
    A handle to the timer
===============================================================================]]
function CreateTimer(name, interval, units, callback, repeating, callbackParam)
	timer = c4_timer:new(name, interval, units, callback, repeating, callbackParam)
	return timer
end

--[[=============================================================================
    StartTimer(handle, ...)

    Description: 
    Starts the timer created by calling the CreateTimer functions

    Parameters:
    handle(timer)   - Handle to a created timer object
    interval(int)   - The amount of the given time between calls to the
                      timers callback function
    units(string)   - The time of time interval used (e.g. SECONDS, MINUTES, ...)
    repeating(bool) - Parameter indicating whether the timer should be
                      called repeatedly until cancelled

    Returns:
    None
===============================================================================]]
function StartTimer(handle, ...)
	handle:StartTimer(...)
end

--[[=============================================================================
    KillTimer(handle)

    Description: 
    Starts the timer created by calling the CreateTimer functions

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    None
===============================================================================]]
function KillTimer(handle)
	handle:KillTimer()
end

--[[=============================================================================
    TimerStarted(handle)

    Description: 
    Identifies whether a timer has been started or not

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    Returns true if a the given timer handle has been started, or false otherwise
===============================================================================]]
function TimerStarted(handle)
	return handle:TimerStarted()
end

--[[=============================================================================
    TimerStopped(handle)

    Description: 
    Identifies whether a timer has been stopped or not

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    Returns true if a the given timer handle has been stopped, or false otherwise
===============================================================================]]
function TimerStopped(handle)
	return handle:TimerStopped()
end

--[[=============================================================================
    GetTimerInterval(handle)

    Description: 
    Gets the interval setting of the given timer

    Parameters:
    handle(timer) - Handle to a created timer object

    Returns:
    Returns the interval setting of the given timer
===============================================================================]]
function GetTimerInterval(handle)
	return handle:GetTimerInterval()
end
