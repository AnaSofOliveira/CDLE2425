public class testes {

    public static void main(String[] args) {
        StringBuilder words = new StringBuilder();
        
        words.append("a");

        System.out.println(words.length());

        
        words.append("b");

        System.out.println(words.length());

        
        words.append("c");

        System.out.println(words.length());

        words.deleteCharAt(0);

        System.out.println(words.length());


        for (String word : words.toString().split(" ")) {
            System.out.println(word + " ");
        }

    }

}
