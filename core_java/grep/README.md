# Java Grep Application

## Introduction

This Java application replicates the functionality of the Linux `grep` command. It recursively searches through a directory tree for lines matching a specified regex pattern and writes all matches to an output file. The project includes two implementations: a traditional loop-based version (`JavaGrepImp`) and a modern stream-based version using lambda expressions (`JavaGrepLambdaImp`).

**Technologies used:**
- Core Java 8 (Streams API, Lambda expressions, File I/O)
- Maven for dependency management and packaging
- SLF4J and Log4j for logging
- Docker for containerization
- IntelliJ IDEA as the development IDE

## Quick Start

**Using Java:**
```bash
# Compile and package the application
mvn clean package

# Run the application
java -jar target/grep.jar <regex> <rootPath> <outFile>

# Example: Find lines containing "Romeo" in text files
java -jar target/grep.jar ".*Romeo.*" ./data ./output/results.txt
```

**Using Docker:**
```bash
# Pull the image from Docker Hub
docker pull humzainam/grep

# Run the container
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/output:/output \
  humzainam/grep ".*Romeo.*" /data /output/results.txt
```

**Arguments:**
- `regex`: Regular expression pattern to search for
- `rootPath`: Root directory to search recursively
- `outFile`: Output file path for matched lines

## Implementation

### Pseudocode - `process` method

```
matchedLines = []

for each file in listFiles(rootPath):
    for each line in readLines(file):
        if containsPattern(line):
            add line to matchedLines

writeToFile(matchedLines)
```

**Lambda/Stream Implementation:**
```
matchedLines = listFiles(rootPath)
    .stream()
    .flatMap(file -> readLines(file).stream())
    .filter(line -> containsPattern(line))
    .collect()

writeToFile(matchedLines)
```

## Test

The application was tested manually using Shakespeare's Romeo and Juliet play as sample data:

1. **Created test directory structure** with the data folder containing the Romeo and Juliet text file
2. **Executed test cases** with different regex patterns to find character names:
   - `".*Romeo.*"` - Find all lines mentioning Romeo
   - `".*Benvolio.*"` - Find all lines mentioning Benvolio
   - `".*Tybalt.*"` - Find all lines mentioning Tybalt
3. **Verified output** by comparing results in the output file against expected matches

The application successfully identified all matching lines from the text file.

## Deployment

The application is containerized using Docker for easy distribution and execution across different environments.

**Dockerfile:**
```dockerfile
FROM eclipse-temurin:8-jre-alpine

WORKDIR /usr/local/app/grep

COPY target/grep*.jar lib/grep.jar

ENTRYPOINT ["java","-jar","lib/grep.jar"]
```

**Build and push to Docker Hub:**
```bash
# Create required directories
mkdir -p data output

# Package the application
mvn clean package

# Build Docker image
docker build -t ${docker_user}/grep .

# Verify the image
docker image ls | grep "grep"

# Test the container
docker run --rm \
  -v $(pwd)/data:/data \
  -v $(pwd)/output:/output \
  ${docker_user}/grep ".*Romeo.*" /data /output/results.txt

# Push to Docker Hub
docker login -u ${docker_user}
docker push ${docker_user}/grep
```

The `-v` flag mounts local directories into the container, allowing the application to access input files and write output to the host machine.

## Improvements

1. **Support multiple root directories**: Allow users to specify multiple search paths in a single execution instead of limiting to one root directory.

2. **Add command-line flags**: Implement options such as `--help` for usage information, `--ignore-case` for case-insensitive matching, and `--version` to display application version.

3. **Progress indicators**: Add visual feedback for large directory scans to show processing status, including number of files scanned and matches found in real-time.
