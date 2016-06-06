import pandas
import matplotlib.pyplot
import csv

title="AWS EC2 image import: timed state transitions"

df5 = pandas.DataFrame.from_csv("ec2importtime.loop-booting.csv")
df5 = df5.rename(index=int, columns={"percent": "loop-booting"})
ax = df5.plot(kind="line", style="--", title=title, colormap="pink", xlim=(0,1600), ylim=(0,105))

df4 = pandas.DataFrame.from_csv("ec2importtime.failure-internal.csv")
df4 = df4.rename(index=int, columns={"percent": "failure-internal"})
ax = df4.plot(ax=ax, kind="line", title=title, colormap="cool_r", xlim=(0,1600), ylim=(0,105))

df3 = pandas.DataFrame.from_csv("ec2importtime.failure-diskvalidation.csv")
df3 = df3.rename(index=int, columns={"percent": "failure-diskvalidation"})
ax = df3.plot(ax=ax, kind="line", title=title, colormap="summer", xlim=(0,1600), ylim=(0,105))

df2 = pandas.DataFrame.from_csv("ec2importtime.failure-os.csv")
df2 = df2.rename(index=int, columns={"percent": "failure-os"})
ax = df2.plot(ax=ax, kind="line", title=title, colormap="coolwarm_r", xlim=(0,1600), ylim=(0,105))

df = pandas.DataFrame.from_csv("ec2importtime.csv")
df = df.rename(index=int, columns={"percent": "success (%)"})
ax = df.plot(ax=ax, kind="line", title=title, colormap="coolwarm", xlim=(0,1600), ylim=(0,105))

reader = csv.reader(open("ec2importtime.csv"))
for row in reader:
	if row[0] == "time":
		continue
	ax.annotate(row[2], xy=(int(row[0]), int(row[1])))

reader = csv.reader(open("ec2importtime.failure-os.csv"))
for row in reader:
	if row[0] == "time" or row[2] in ("pending", "validating", "validated", "converting", "updating"):
		continue
	ax.annotate(row[2], xy=(int(row[0]), int(row[1])))

reader = csv.reader(open("ec2importtime.failure-diskvalidation.csv"))
for row in reader:
	if row[0] == "time" or row[2] in ("pending", "validating"):
		continue
	ax.annotate(row[2], xy=(int(row[0]), int(row[1])))

reader = csv.reader(open("ec2importtime.failure-internal.csv"))
for row in reader:
	if row[2] in ("internalerror",):
		ax.annotate(row[2], xy=(int(row[0]), int(row[1])))

reader = csv.reader(open("ec2importtime.loop-booting.csv"))
for row in reader:
	if row[2] in ("booting-loop",):
		ax.annotate(row[2], xy=(int(row[0]) - 200, int(row[1])))

#patches, labels = ax.get_legend_handles_labels()
#ax.legend(patches, labels, loc="lower left")

matplotlib.pyplot.show()
