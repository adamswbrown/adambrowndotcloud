---
title: File Manipulation
weight: 40
menu:
  notes:
    name: File Manipulation
    identifier: notes-go-advanced-files-en
    parent: notes-go-advanced-en
    weight: 10
---

<!-- Condition -->
{{< note title="Condition">}}

```go
if day == "sunday" || day == "saturday" {
  rest()
} else if day == "monday" && isTired() {
  groan()
} else {
  work()
}
```

```go
if _, err := doThing(); err != nil {
  fmt.Println("Uh oh")
```

{{< /note >}}