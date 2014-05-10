## Hireology Homework
This repo contains my solutions to the Software Engineer homework set provided by Hireology.

The solution set has yet to be completed. Below is a list of items that are included:

#### Part 1 (Writen Questions)
    + Question 1: Memcache (Completed)
    + Question 2: SomeController (Completed)

#### Part 2 (Programming Problems)
    + Question 1: File Parser using Regex and JSON serializer. (Completed)
    + Question 2: Org-User-Role Kata (work in progress)

======

### The original README from Hireology
### Instructions

There are two parts to the Software Engineer Homework set. Part 1 is written answer, and Part 2 is a set of programmable problems. Please fork this repo to your GitHub account, add your work to the forked repo, and send a pull request when your work is complete.

### Part 1 - Written Questions

1. How can Memcache improve a site’s performance? Include a description about how data is stored and retrieved in a multi-node configuration.

2. Please take a look at [this controller action](https://github.com/Hireology/homework/blob/master/some_controller.rb). Please tell us what you think of this code and how you would make it better.

### Part 2 - Programming Problems

1) Write a program using regular expressions to parse a file where each line is of the following format:

`$4.99 TXT MESSAGING – 250 09/29 – 10/28 4.99`

For each line in the input file, the program should output three pieces of information parsed from the line in the following JSON format (using the above example line):

```
{
  “feature” : “TXT MESSAGING – 250”,
  “date_range” : “09/29 – 10/28”,
  “price” : 4.99 // use the last dollar amount in the line
}
```

2) Please complete a set of classes for the problem described in [this blog post](http://www.adomokos.com/2012/10/the-organizations-users-roles-kata.html). Please do not create a database backend for this. Test doubles should work fine.
