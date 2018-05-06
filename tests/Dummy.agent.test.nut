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

const AZURE_DEVICE_CONN_STRING = "@{AZURE_DEVICE_CONN_STRING}";

class DummyTestCase extends ImpTestCase {
    _azureMqttClient = null;

    function setUp() {
        _azureMqttClient = AzureIoTHub.Client(AZURE_DEVICE_CONN_STRING, function (err) {}.bindenv(this));
    }

    function testConnect() {
        _azureMqttClient.connect();
    }

    function testDisconnect() {
        _azureMqttClient.disconnect();
    }

    function testIsConnected() {
        _azureMqttClient.isConnected();
    }

    function testSendMessage() {
        _azureMqttClient.sendMessage(AzureIoTHub.Message(""));
    }

    function testEnableMessageReceiving() {
        _azureMqttClient.enableMessageReceiving(function (msg) {}.bindenv(this));
    }

    function testEnableTwin() {
        _azureMqttClient.enableTwin(function (version, props) {}.bindenv(this));
    }

    function testRetrieveTwinProperties() {
        _azureMqttClient.retrieveTwinProperties(function (err, reportedProps, desiredProps) {}.bindenv(this));
    }

    function testUpdateTwinProperties() {
        _azureMqttClient.updateTwinProperties({});
    }

    function testEnableDirectMethods() {
        _azureMqttClient.enableDirectMethods(function (name, params) {}.bindenv(this));
    }
}