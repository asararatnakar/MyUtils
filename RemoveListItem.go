package main
// Remove an item from a list https://play.golang.org/p/yq8gCTk7Eh
import "fmt"

func main() {
	a := []string{"12345", "23456", "34567"}
	fmt.Println("\n####### Original List : " , a)
	word := "23456"
        index := indexOf(word, a)
	if  index>= 0 {
		a = append(a[:index], a[index+1:]...)
		fmt.Printf("\nAfter removing %s, Now the list is %v\n", word, a)
	}
}

func indexOf(word string, data []string) int {
	for k, v := range data {
		if word == v {
			return k
		}
	}
	fmt.Printf("\n**** Couldn't find %s in the list *****\n", word)
	return -1
}
