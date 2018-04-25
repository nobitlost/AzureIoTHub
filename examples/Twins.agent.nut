// MIT License
//
// Copyright 2018 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#require "AzureIoTHub.agent.lib.nut:3.0.0"

const PROPERTY_NAME = "test";

class TwinsExample {
    _azureClient = null;

    _connectionString = null;
    _deviceConnString = null;

    constructor(connectionString) {
        _connectionString = connectionString;
    }

    function start() {
        registerDevice(function (err) {
            if (err == null) {
                _azureClient = AzureIoTHub.Client(_deviceConnString,
                    _onConnected.bindenv(this), _onDisconnected.bindenv(this));
                _azureClient.connect();
            }
        }.bindenv(this));
    }

    function registerDevice(onCompleted) {
        local deviceID = imp.configparams.deviceid;
        local hostName = AzureIoTHub.ConnectionString.Parse(_connectionString).HostName;
        local registry = AzureIoTHub.Registry(_connectionString);
        // Find this device in the registry
        registry.get(deviceID, function(err, iotHubDev) {
            if (err) {
                if (err.response.statuscode == 404) {
                    // No such device, let's create it, connect & open receiver
                    registry.create({"deviceId" : deviceID}, function(error, iotHubDevice) {
                        if (error) {
                            server.error(error.message);
                            onCompleted(error);
                        } else {
                            _deviceConnString = iotHubDevice.connectionString(hostName);
                            server.log("Device created: " + iotHubDevice.getBody().deviceId);
                            onCompleted(null);
                        }
                    }.bindenv(this));
                } else {
                    server.error(err.message);
                    onCompleted(err);
                }
            } else {
                _deviceConnString = iotHubDev.connectionString(hostName);
                // Found device, let's connect & open receiver
                server.log("Device already registered as " + iotHubDev.getBody().deviceId);
                onCompleted(null);
            }
        }.bindenv(this));
    }

    // -------------------- PRIVATE METHODS -------------------- //

    function _onConnected(err) {
        if (err != 0) {
            server.error("AzureIoTHub connect failed: " + err);
            return;
        }
        server.log("Connected!");
        _azureClient.enableTwin(_onRequest.bindenv(this), function (err) {
            if (err != 0) {
                server.error("AzureIoTHub enableTwin failed: " + err);
            } else {
                _azureClient.retrieveTwinProperties(_onRetrieve.bindenv(this));
            }
        }.bindenv(this));
    }

    function _onDisconnected(err) {
        server.log("Disconnected!");
        server.log("Reconnecting...");
        _azureClient.connect();
    }

    function _onRetrieve(err, reportedProps, desiredProps) {
        if (err != 0) {
            server.error("AzureIoTHub retrieveTwinProperties failed: " + err);
            return;
        }
        server.log("Twin properties retrieved:");
        server.log("reported props:");
        _printTable(reportedProps);
        server.log("desired props:");
        _printTable(desiredProps);
    }

    function _onRequest(version, props) {
        server.log("Desired props received:");
        server.log("version = " + version);
        server.log("props:");
        _printTable(props);
        if (PROPERTY_NAME in props) {
            server.log("Updating reported properties...")
            local propUpd = {};
            propUpd[PROPERTY_NAME] <- props[PROPERTY_NAME];

            _azureClient.updateTwinProperties(propUpd, function (err) {
                if (err != 0) {
                    server.error("AzureIoTHub updateTwinProperties failed: " + err);
                } else {
                    server.log("Reported properties successfully updated");
                }
            });
        } else {
            server.log(format("No property \"%s\" in desired properties", PROPERTY_NAME));
        }
    }

    function _printTable(tbl) {
        foreach (k, v in tbl) {
            server.log(k + " : " + v);
        }
    }
}

// RUNTIME
// ---------------------------------------------------------------------------------

// AzureIoTHub constants
// ---------------------------------------------------------------------------------
const AZURE_CONN_STRING = "<YOUR_AZURE_CONN_STRING>";

// Start application
twinsExample <- TwinsExample(AZURE_CONN_STRING);
twinsExample.start();
