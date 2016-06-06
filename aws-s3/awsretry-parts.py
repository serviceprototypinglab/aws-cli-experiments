import pandas
import matplotlib.pyplot

def loadframe(filename):
	df = pandas.DataFrame.from_csv(filename)

	df["success (%)"] = df["overallsuccesspercent"]

	del df["(re)tries"]
	del df["success"]
	del df["overallsuccess"]
	del df["overallsuccesspercent"]

	return df

dfs = []
dfs.append(loadframe("awsretry-parts.delay-5000ms.eth1.3.run1.csv"))
dfs.append(loadframe("awsretry-parts.delay-5000ms.eth1.3.run2.csv"))
dfs.append(loadframe("awsretry-parts.delay-5000ms.eth1.3.run3.csv"))
dfs.append(loadframe("awsretry-parts.delay-6000ms.wlan0.3.csv"))
dfs.append(loadframe("awsretry-parts.delay-8000ms.wlan0.3.csv"))
dfs.append(loadframe("awsretry-parts.delay-15000ms.eth1.5.csv"))
dfs.append(loadframe("awsretry-parts.delay-10000ms.wlan0.-1.csv"))

names = []
names.append("5s; 3 attempts/a")
names.append("5s; 3 attempts/b")
names.append("5s; 3 attempts/c")
names.append("6s; 3 attempts")
names.append("8s; 3 attempts")
names.append("15s; 5 attempts")
names.append("10s; unlimited attempts")

colors = []
colors.append([(0, 0, 1.0)] * len(dfs[0].index))
colors.append([(0, 0, 0.8)] * len(dfs[1].index))
colors.append([(0, 0, 0.6)] * len(dfs[2].index))
colors.append([(0, 0.6, 0.5)] * len(dfs[3].index))
colors.append([(0, 1.0, 0.5)] * len(dfs[4].index))
colors.append([(1, 0.5, 0.5)] * len(dfs[5].index))
colors.append([(1, 1, 0)] * len(dfs[6].index))

ax = None
for df, color, name in zip(dfs, colors, names):
	ax = df.plot(ax=ax, kind="scatter", title="AWS S3 file upload empirical observation: ø retries", colormap="coolwarm_r", y="success (%)", x="overhead", c=color, s=80, label=name, xticks=[1,2,3,6,9,10], yticks=[30,40,50,60,70,80,90,100], ylim=(0,109))

patches, labels = ax.get_legend_handles_labels()
ax.legend(patches, labels, loc="lower right")

matplotlib.pyplot.show()
