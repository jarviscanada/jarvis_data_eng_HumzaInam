package ca.jrvs.apps.grep;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.log4j.BasicConfigurator;

/**
 * Java Grep App
 * Searches for a regex pattern in files within a directory tree and writes matches to an output file.
 * @author Humza Inam
 */
public class JavaGrepImp implements JavaGrep{

    final Logger logger  = LoggerFactory.getLogger(JavaGrepImp.class);

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

        JavaGrepImp javaGrepImp = new JavaGrepImp();
        javaGrepImp.setRegex(args[0]);
        javaGrepImp.setRootPath(args[1]);
        javaGrepImp.setOutFile(args[2]);

        try {
            javaGrepImp.process();
        } catch (Exception ex) {
            javaGrepImp.logger.error("Error: Unable to process", ex);
        }
    }

    /**
     * Processes all files in the root directory, searches for pattern matches, and writes results to output file.
     * @throws IOException if file operations fail
     */
    public void process() throws IOException {

        List<String> matchedLines = new ArrayList<>();

        List<File> files = listFiles(getRootPath());

        for (File f: files) {
            List<String> lines = readLines(f);

            for (String line: lines) {
                if (containsPattern(line)){
                    matchedLines.add(line);
                }
            }
        }

        writeToFile(matchedLines);
    }

    /**
     * Recursively lists all files in a directory.
     * @param rootDir the root directory path
     * @return list of all files found
     */
    public List<File> listFiles(String rootDir) {
        List<File> files = new ArrayList<>();
        File dir = new File(rootDir);

        File[] items = dir.listFiles();

        if (items == null) {
            return files;
        }

        for (File f : items) {
            if (f.isDirectory()){
                files.addAll(listFiles(f.getAbsolutePath()));
            }
            else if(f.isFile()){
                files.add(f);
            }
        }
        return files;
    }

    /**
     * Reads all lines from a file.
     * @param inputFile the file to read
     * @return list of lines from the file
     * @throws IOException if file cannot be read
     */
    public List<String> readLines(File inputFile) throws IOException {
        List<String> lines = new ArrayList<>();

        BufferedReader reader = new BufferedReader(new FileReader(inputFile));

        String line;

        while ((line = reader.readLine()) != null) {
            lines.add(line);
        }

        reader.close();

        return lines;
    }

    /**
     * Checks if a line matches the regex pattern.
     * @param line the line to check
     * @return true if line matches pattern, false otherwise
     */
    public boolean containsPattern(String line) {
        return line.matches(getRegex());
    }

    /**
     * Writes lines to the output file.
     * @param lines the lines to write
     * @throws IOException if file cannot be written
     */
    public void writeToFile(List<String> lines) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter(getOutFile()));

        for (String line : lines) {
            writer.write(line);
            writer.newLine();
        }

        writer.close();

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