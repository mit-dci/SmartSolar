package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var text string
	for text != "q" {
		fmt.Print("Hit Enter to Request (q to quit) ")
		scanner.Scan()
		text = scanner.Text()
		if text == "q" {
			break
		} else {
			jsonData := fmt.Sprintf(`{"jsonrpc":"2.0", "method":"eth_call", "params":[{"to": "0x763d5f4bfc632686eeb5681ee72500464e845f1c", "data": "0x49a4e50d"}, "latest"], "id":4}`)
			response, err := http.Post("https://rinkeby.infura.io/gnNuNKvHFmjf9xkJ0StE", "application/json", strings.NewReader(jsonData))

			if err != nil {

				fmt.Printf("Request to INFURA failed with an error: %s\n", err)
				fmt.Println()

			} else {
				data, _ := ioutil.ReadAll(response.Body)

				fmt.Println("INFURA response:")
				fmt.Println(string(data))
			}
		}
	}
}
