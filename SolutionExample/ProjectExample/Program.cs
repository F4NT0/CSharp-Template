namespace ProjectExample
{
    public class Program
    {
      public static string GetHelloWorld()
      {
          return "Hello World!";
      }

      public static void Main(string[] args)
      {
          string test = GetHelloWorld();
          Console.WriteLine(test);
      }
    }
}
