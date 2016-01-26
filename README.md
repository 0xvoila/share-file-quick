# Share any file or folder on your computer directly from terminal.
`getlink` is command line utility to generate sharable link of **any file or folder on your machine** to share it with anyone. You can create a password protected file-share by passing `-p` flag to this shell script. There is a limit of 100MB file can be shared.

# Usage
## No password protected file
`getlink.sh file1 file2 ~/folder3`

**output**
`https://s3-us-west-2.amazonaws.com/shaw-public-bucket/kSBIPW6jD8.zip`

## Password protected sharing
`getlink.sh -p file1 file2 ~/folder3`

**output**
`https://s3-us-west-2.amazonaws.com/shaw-public-bucket/kSBIPW6jD8.zip`
`password - 14345`


# Bug Report
Let me know if you find a bug and request a new feature. Either ping me on hipchat or email me at **amit.a@shawacademy.com**. 
Better would be if you can create a issue here itself. 

# License

**Owner** - ShawAcademy private limited

**Author** - Amit Aggarwal [amit.a@shawacademy.com](amit.a@shawacademy.com)
