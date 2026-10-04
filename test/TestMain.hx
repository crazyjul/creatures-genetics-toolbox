import utest.Runner;
import utest.ui.Report;

class TestMain {
    public static function main() {
        var runner = new Runner();
        runner.addCase(new TestGenome());
        runner.addCase(new TestBrainGenes());
        runner.addCase(new TestOtherGenes());
        runner.addCase(new TestBiochemistryGenes());
        Report.create(runner);
        runner.run();
    }
}
