package ca.jrvs.apps.practice;

import java.util.Arrays;
import java.util.List;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import java.util.stream.DoubleStream;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class LambdaStreamExcTest {

    public static void main(String[] args) {
        LambdaStreamExc lse = new LambdaStreamExcImpl();

        System.out.println("=== Test 1: createStrStream ===");
        testCreateStrStream(lse);

        System.out.println("\n=== Test 2: toUpperCase ===");
        testToUpperCase(lse);

        System.out.println("\n=== Test 3: filter ===");
        testFilter(lse);

        System.out.println("\n=== Test 4: createIntStream from array ===");
        testCreateIntStreamArray(lse);

        System.out.println("\n=== Test 5: toList (Stream) ===");
        testToListStream(lse);

        System.out.println("\n=== Test 6: toList (IntStream) ===");
        testToListIntStream(lse);

        System.out.println("\n=== Test 7: createIntStream range ===");
        testCreateIntStreamRange(lse);

        System.out.println("\n=== Test 8: squareRootIntStream ===");
        testSquareRootIntStream(lse);

        System.out.println("\n=== Test 9: getOdd ===");
        testGetOdd(lse);

        System.out.println("\n=== Test 10: getLambdaPrinter ===");
        testGetLambdaPrinter(lse);

        System.out.println("\n=== Test 11: printMessages ===");
        testPrintMessages(lse);

        System.out.println("\n=== Test 12: printOdd ===");
        testPrintOdd(lse);

        System.out.println("\n=== Test 13: flatNestedInt ===");
        testFlatNestedInt(lse);

        System.out.println("\n=== All tests completed! ===");
    }

    private static void testCreateStrStream(LambdaStreamExc lse) {
        Stream<String> stream = lse.createStrStream("apple", "banana", "cherry");
        List<String> result = stream.collect(Collectors.toList());
        System.out.println("Result: " + result);
        assert result.equals(Arrays.asList("apple", "banana", "cherry"));
    }

    private static void testToUpperCase(LambdaStreamExc lse) {
        Stream<String> stream = lse.toUpperCase("hello", "world");
        List<String> result = stream.collect(Collectors.toList());
        System.out.println("Result: " + result);
        assert result.equals(Arrays.asList("HELLO", "WORLD"));
    }

    private static void testFilter(LambdaStreamExc lse) {
        Stream<String> input = Stream.of("apple", "dog", "banana", "cherry", "fig");
        Stream<String> filtered = lse.filter(input, "a");
        List<String> result = filtered.collect(Collectors.toList());
        System.out.println("Result (filter out strings with 'a'): " + result);
        assert result.equals(Arrays.asList("dog", "cherry", "fig"));
    }

    private static void testCreateIntStreamArray(LambdaStreamExc lse) {
        int[] arr = {1, 2, 3, 4, 5};
        IntStream stream = lse.createIntStream(arr);
        int[] result = stream.toArray();
        System.out.println("Result: " + Arrays.toString(result));
        assert Arrays.equals(result, arr);
    }

    private static void testToListStream(LambdaStreamExc lse) {
        Stream<String> stream = Stream.of("a", "b", "c");
        List<String> result = lse.toList(stream);
        System.out.println("Result: " + result);
        assert result.equals(Arrays.asList("a", "b", "c"));
    }

    private static void testToListIntStream(LambdaStreamExc lse) {
        IntStream stream = IntStream.of(10, 20, 30);
        List<Integer> result = lse.toList(stream);
        System.out.println("Result: " + result);
        assert result.equals(Arrays.asList(10, 20, 30));
    }

    private static void testCreateIntStreamRange(LambdaStreamExc lse) {
        IntStream stream = lse.createIntStream(1, 5);
        int[] result = stream.toArray();
        System.out.println("Result (1 to 5 inclusive): " + Arrays.toString(result));
        assert Arrays.equals(result, new int[]{1, 2, 3, 4, 5});
    }

    private static void testSquareRootIntStream(LambdaStreamExc lse) {
        IntStream input = IntStream.of(1, 4, 9, 16);
        DoubleStream result = lse.squareRootIntStream(input);
        double[] resultArray = result.toArray();
        System.out.println("Result: " + Arrays.toString(resultArray));
        assert Arrays.equals(resultArray, new double[]{1.0, 2.0, 3.0, 4.0});
    }

    private static void testGetOdd(LambdaStreamExc lse) {
        IntStream input = IntStream.rangeClosed(1, 10);
        IntStream odd = lse.getOdd(input);
        int[] result = odd.toArray();
        System.out.println("Result: " + Arrays.toString(result));
        assert Arrays.equals(result, new int[]{1, 3, 5, 7, 9});
    }

    private static void testGetLambdaPrinter(LambdaStreamExc lse) {
        Consumer<String> printer = lse.getLambdaPrinter("start>", "<end");
        printer.accept("Message body");
        // Expected output: start>Message body<end
    }

    private static void testPrintMessages(LambdaStreamExc lse) {
        String[] messages = {"a", "b", "c"};
        lse.printMessages(messages, lse.getLambdaPrinter("msg:", "!"));
        // Expected output:
        // msg:a!
        // msg:b!
        // msg:c!
    }

    private static void testPrintOdd(LambdaStreamExc lse) {
        lse.printOdd(lse.createIntStream(0, 5), lse.getLambdaPrinter("odd number:", "!"));
        // Expected output:
        // odd number:1!
        // odd number:3!
        // odd number:5!
    }

    private static void testFlatNestedInt(LambdaStreamExc lse) {
        Stream<List<Integer>> nested = Stream.of(
                Arrays.asList(1, 2, 3),
                Arrays.asList(4, 5),
                Arrays.asList(6, 7, 8, 9)
        );
        Stream<Integer> flattened = lse.flatNestedInt(nested);
        List<Integer> result = flattened.collect(Collectors.toList());
        System.out.println("Result: " + result);
        assert result.equals(Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9));
    }
}