using Microsoft.VisualStudio.TestTools.UnitTesting;
using ProjectExample;

namespace ProjectExampleTests;

[TestClass]
public class UnitTest1
{
    [TestMethod]
    public void TestHelloWorld()
    {
        // Arrange
        //Program program = new Program();
        
        // Act
        string result = Program.GetHelloWorld();

        // Assert
        Assert.AreEqual("Hello World!", result);
    }
}
