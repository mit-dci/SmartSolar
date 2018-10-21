//Original Author: bdjukic

package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/signal"
	"strings"

	"github.com/yosssi/gmq/mqtt"
	"github.com/yosssi/gmq/mqtt/client"
)

func main() {
	// Set up channel on which to send signal notifications.
	sigc := make(chan os.Signal, 1)
	signal.Notify(sigc, os.Interrupt, os.Kill)

	// Create an MQTT Client.
	cli := client.New(&client.Options{
		// Define the processing of the error handler.
		ErrorHandler: func(err error) {
			fmt.Println(err)
		},
	})

	// Terminate the Client.
	defer cli.Terminate()

	// Connect to the MQTT Server.
	err := cli.Connect(&client.ConnectOptions{
		Network:  "tcp",
		Address:  "m13.cloudmqtt.com:12423",
		ClientID: []byte("Infura-Client"),
		UserName: []byte("skupntaq"),
		Password: []byte("yRS1mpvJp8su"),
	})
	if err != nil {
		panic(err)
	}

	// Subscribe to topics.
	err = cli.Subscribe(&client.SubscribeOptions{
		SubReqs: []*client.SubReq{
			&client.SubReq{
				TopicFilter: []byte("testTopic"),
				QoS:         mqtt.QoS0,
				// Define the processing of the message handler.
				Handler: func(topicName, message []byte) {
					fmt.Println(("New Transaction received"))

					jsonData := fmt.Sprintf(`{"jsonrpc":"2.0", "method":"eth_call", "params":[{"to": "0xec67fad6efe7346d18c908275b879d04454a3dd0", "data": "0x6ffa1caa0000000000000000000000000000000000000000000000000000000000000005"}, "latest"], "id":1}`)
					response, err := http.Post("https://rinkeby.infura.io/gnNuNKvHFmjf9xkJ0StE", "application/json", strings.NewReader(jsonData))

					if err != nil {
						fmt.Printf("Request to INFURA failed with an error: %s\n", err)
						fmt.Println()
					} else {
						data, _ := ioutil.ReadAll(response.Body)

						fmt.Println("INFURA response:")
						fmt.Println(string(data))
						fmt.Println()
					}
				},
			},
		},
	})
	if err != nil {
		panic(err)
	}

	// Wait for receiving a signal.
	<-sigc

	// Disconnect the Network Connection.
	if err := cli.Disconnect(); err != nil {
		panic(err)
	}
}
