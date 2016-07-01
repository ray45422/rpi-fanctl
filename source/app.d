import std.stdio;
import std.stdio: File;
import core.thread;
import dgpio;

void main(){
	GPIO gpio = new GPIO(17);
	gpio.setOutput();
	gpio.setHigh();
	Thread.sleep(dur!("seconds")(10));
	gpio.deactivate();
}
