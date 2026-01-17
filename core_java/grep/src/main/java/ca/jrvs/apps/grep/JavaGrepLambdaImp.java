package ca.jrvs.apps.grep;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.log4j.BasicConfigurator;

/**
 * Java Grep App - Lambda/Stream Implementation
 * Searches for a regex pattern in files within a directory tree and writes matches to an output file.
 * Uses Java 8+ Streams and Lambda expressions for functional programming approach.
 * @author Humza Inam
 */
public class JavaGrepLambdaImp implements JavaGrep {

    final Logger logger = LoggerFactory.getLogger(JavaGrepLambdaImp.class);

    private String rootPath;
    private String regex;
    private String outFile;

    /**
     * Main method to execute the grep application.
     * @param args command line arguments: regex, rootPath, outFile
     */
    public static void main(String[] args) {
        if (args.length != 3) {
            throw new IllegalArgumentException("USAGE: JavaGrep regex rootPath outFile");
        }

        BasicConfigurator.configure();

        JavaGrepLambdaImp javaGrepLambdaImp = new JavaGrepLambdaImp();
        javaGrepLambdaImp.setRegex(args[0]);
        javaGrepLambdaImp.setRootPath(args[1]);
        javaGrepLambdaImp.setOutFile(args[2]);

        try {
            javaGrepLambdaImp.process();
        } catch (Exception ex) {
            javaGrepLambdaImp.logger.error("Error: Unable to process", ex);
        }
    }

    /**
     * Processes all files in the root directory using streams.
     * @throws IOException if file operations fail
     */
    @Override
    public void process() throws IOException {
        List<String> matchedLines = listFiles(getRootPath()).stream()
                .flatMap(file -> {
                    try {
                        return readLines(file).stream();
                    } catch (IOException e) {
                        logger.error("Error reading file: " + file.getAbsolutePath(), e);
                        return Stream.empty();
                    }
                })
                .filter(this::containsPattern)
                .collect(Collectors.toList());

        writeToFile(matchedLines);
    }

    /**
     * Recursively lists all files in a directory using streams.
     * @param rootDir the root directory path
     * @return list of all files found
     */
    @Override
    public List<File> listFiles(String rootDir) {
        try {
            return Files.walk(Paths.get(rootDir))
                    .filter(Files::isRegularFile)
                    .map(Path::toFile)
                    .collect(Collectors.toList());
        } catch (IOException e) {
            logger.error("Error listing files in directory: " + rootDir, e);
            return Collections.emptyList();
        }
    }

    /**
     * Reads all lines from a file using streams.
     * @param inputFile the file to read
     * @return list of lines from the file
     * @throws IOException if file cannot be read
     */
    @Override
    public List<String> readLines(File inputFile) throws IOException {
        return Files.lines(inputFile.toPath())
                .collect(Collectors.toList());
    }

    /**
     * Checks if a line matches the regex pattern.
     * @param line the line to check
     * @return true if line matches pattern, false otherwise
     */
    @Override
    public boolean containsPattern(String line) {
        return line.matches(getRegex());
    }

    /**
     * Writes lines to the output file using streams.
     * @param lines the lines to write
     * @throws IOException if file cannot be written
     */
    @Override
    public void writeToFile(List<String> lines) throws IOException {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(getOutFile()))) {
            lines.forEach(line -> {
                try {
                    writer.write(line);
                    writer.newLine();
                } catch (IOException e) {
                    logger.error("Error writing line to file", e);
                }
            });
        }
    }

    // Alternative writeToFile using Files.write (more concise)
    public void writeToFileAlt(List<String> lines) throws IOException {
        Files.write(Paths.get(getOutFile()), lines);
    }

    public String getRootPath() {
        return this.rootPath;
    }

    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }

    public String getRegex() {
        return this.regex;
    }

    public void setRegex(String regex) {
        this.regex = regex;
    }

    public String getOutFile() {
        return this.outFile;
    }

    public void setOutFile(String outFile) {
        this.outFile = outFile;
    }
}