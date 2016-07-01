import std.stdio;
import std.stdio:File;
import std.file;
import std.conv;
import std.string;
import std.math;
import core.thread;
import dgpio;

GPIO gpio;
void startup(){
	gpio.setHigh();
	Thread.sleep(dur!("seconds")(5));
}
int main(string[] args){
	enum string pidFile="/run/fanctl.pid";
	enum string tempFile="/sys/class/thermal/thermal_zone0/temp";
	int tempMax=40;
	int tempMin=20;
	int temp;
	uint freq=200;
	uint pulse=1000000/freq;
	int power;
	int powerPrev=0;
	uint c=0;
	writeln(getpid());
	std.file.write(pidFile,getpid.to!string()~"\n");
	gpio = new GPIO(17);
	gpio.setOutput();
	while(true){
		{
			if(!std.file.exists(pidFile)){
				break;
			}
			File f = File(tempFile, "r");
			temp=f.readln.chomp.to!uint;
			power=(temp-tempMin*1000)/(tempMax-tempMin)/10;
			if(power<20){
				power=0;
			}
			if(power>100){
				power=100;
			}
			if(powerPrev==0 && power>0){
				startup();
			}
		}
		uint waitTime=pulse/100*power;
		for(int i=0;i<freq;++i){
			if(power!=0){
				gpio.setHigh();
				Thread.sleep(dur!("usecs")(waitTime));
			}
			if(power!=100){
				gpio.setLow();
				Thread.sleep(dur!("usecs")(pulse-waitTime));
			}
		}
		powerPrev=power;
	}
	gpio.deactivate();
	return 0;
}
