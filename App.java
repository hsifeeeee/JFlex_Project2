public class App {
     public static void main(String argv[]) {
    if (argv.length == 0) {
      System.out.println("Usage : java RubyLexer <inputfile>");
    }
    else {
      for (int i = 0; i < argv.length; i++) {
        RubyLexer scanner = null;
        try {
          scanner = new RubyLexer( new java.io.FileReader(argv[i]) );
          do {
            System.out.println(scanner.yylex());
          } while (!scanner.yyatEOF());

        }
        catch (java.io.FileNotFoundException e) {
          System.out.println("File not found : \""+argv[i]+"\"");
        }
        catch (java.io.IOException e) {
          System.out.println("IO error scanning file \""+argv[i]+"\"");
          System.out.println(e);
        }
        catch (Exception e) {
          System.out.println("Unexpected exception:");
          e.printStackTrace();
        }
      }
    }
  }
}