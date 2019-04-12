# Summary: Averaging GPS Segments
This is a description of my idea that I implemented for the [**Averaging GPS Segments**](http://cs.uef.fi/sipu/segments) problem. More information about the problem can be found in the problem’s website, so we’ll skip introducing the problem and go straightly onto describing the proposed method for solving the problem.

Though I’ve got more ideas to improve the accuracy (which will probably take some time to implement), currently, the method has achieved about 66% training accuracy according to the problem website. The implementation is available on GitHub in R Language: [Implementation](https://github.com/mohamad-amin/AveragingGPSSegments)

I’m going to describe the method in six main sections:

1. Initial idea
2. Choosing the properties of the model
3. Outlier segment detection
4. Implementation and sample results
5. Conclusion
6. Citations
# 1. Initial Idea
----------

The main idea behind this method is to watch each set from another perspective, in which the connections between each point in the segments are removed. Then we are faced with a 3-dimensional tabular data; the first dimension points to the segment in which the point lies (regarded as $$t$$), and the second ($$x$$) and third ($$y$$) dimensions show the coordinate for the point in the 2d axis.
For example, for set 1, we have:

![The original representation](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555074187289_Screen+Shot+2019-04-12+at+5.32.59+PM.png)
![Plotting the segments without the lines in between](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555074085626_Screen+Shot+2019-04-12+at+5.31.16+PM.png)
![Viewing the segments as tabular data](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555074088677_Screen+Shot+2019-04-12+at+5.30.43+PM.png)


If we view the data form such perspective, then probably a simple linear regression, or more precisely, a piecewise linear regression would be a good approximation of the correct segment. Also choosing the start and end points, choosing the number of knots and detecting the outlier segments would be a great challenge. 

The simple linear regression and the piecewise linear regression (**linear spline**) with some outlier removals showed some good approximations:

![X0 is $$x$$ and X1 is $$y$$ here, linear regression](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555074533000_IMAGE+2019-04-12+173852.jpg)
![X0 is $$x$$ and X1 is $$y$$ here, linear spline](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555074521954_IMAGE+2019-04-12+173841.jpg)


Using the [**linear spline**](https://www.analyticsvidhya.com/blog/2018/03/introduction-regression-splines-python-codes/) ****model was the main reason for using R language here, as the linear spline model isn’t available in python (actually, it is somehow available [here](http://lagrange.univ-lyon1.fr/docs/scipy/0.17.1/generated/scipy.interpolate.interp1d.html) as `interp1d`, but it’s so limited as it doesn’t offer parameter tuning and choosing the number of knots, and therefore is useless for us).

As the results showed, using splines for the approximation seems a good choice, but we should answer these questions to be able to complete the method and make it usable:

- How to choose the predictor and the target based on y an x. which choice gives a better result?
- How to set the start and end points for the output segments based on the linear spline.
- How to choose the number of knots (points in segments) for the linear spline.

These questions are answered in the next section.

# 2. Choosing the properties of the model
----------

We divide this section into three parts, each part answering one of the questions mentioned in the end of the previous section.

## **Choosing the predictor and the target**

For choosing the predictor, the idea was to choose the variable among which there is a higher variance. As the input data is normalized, choosing the variable with the higher variance corresponds to higher accuracy in predicting the other variable and therefore (assuming other factors such as the start and endpoints constant) a more exact approximation of the ground truth for the segments.
For example, in the first set, $$x$$ is the predictor and $$y$$ is the target for our linear spline model.
But in the 7th set, $$y$$ seems a better choice as the predictor.
****
![Set 7: choosing $$y$$ as the predictor yields a better result](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555075878426_Screen+Shot+2019-04-12+at+6.01.10+PM.png)

## **Choosing the start and end points**

Here, for simplicity we suppose the variable $$x$$ is selected as the predictor and $$y$$ is the target. For choosing the start and end points, the idea was to aggregate over all segments to find the points with the least and most $$x$$ values in each segment. Suppose we accumulate this information in vectors $$xs$$ (starting $$x$$s in each group) and $$xe$$ (ending $$x$$s in each group). Then we choose the knots of the linear spline according to the following algorithm:

1. $$start = \overline{xs} + \hat{se}(xs)$$
2. $$end = \overline{xe} - \hat{se}(xe)$$
## **Choosing the number of knots**

We choose the number of knots used in the linear spline according to the following algorithm:

1. $$m\_knots = \text{average of the count of points in each segment of the set}$$
2. $$knots = \text{sequence from } start \text{ to } end \text{ by } m\_knots$$

After fitting the linear spline with the knots as $$knots$$, we’ll add $$\overline{xs}$$ and $$\overline{xe}$$ to the array of $$knots$$ for producing the final approximated segment for each set.

After doing some tests using this algorithm, I concluded that using simple linear regression on the data for the sets in **which** $$m\_knots$$ **is less than 4**, produces better results. This is intuitive because we don’t have to use the power of linear splines where there are merely no knots! So I used simple linear regression in these cases, and the final segment **for the sets in which** $$m\_knots < 3$$ ****is the prediction of the linear regression model on $$x$$ as $$(start, end)$$. It’s a simple line like this:
$$(start, lm(start)) \to (end, lm(end))$$
where $$lm$$ indicates the linear regression model’s prediction on input.

# 3. Outlier segment detection
----------

As viewing the training set suggests, in cases like set 9 and set 1, which are depicted below, outlier detection can be a very good approach to optimize the prediction.

![set 9: two potential outlier segments](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555077270070_Screen+Shot+2019-04-12+at+6.24.22+PM.png)
![set 1: one potential outlier segment](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555077393246_Screen+Shot+2019-04-12+at+6.26.24+PM.png)


I chose to implement the DBScan clustering algorithm to detect the outlier segments, as the algorithm detect the outliers according to the density of the points in a region, which seems rational here. We first run a DBScan on the input set, with $$eps=.05$$ and $$MinPts = \text{count of segments in the set}$$, and identify the segments with at least 1 outlier point in them. If the count of segments detected as outlier are more than half of all of the segments, we increase the $$eps$$ by $$0.01$$ and again run the DBScan as mentioned. The algorithm for this is described below:

1. $$eps = .05$$, $$count\_of\_groups = \text{number of segments in the input set}$$
2. Perform DBScan on the set. with eps as $$eps$$ and min points as $$count\_of\_groups$$. save the id of segments with at least one outlier point in $$outlier\_segments$$ list.
3. If the length of $$outlier\_segments$$ list is more than $$count\_of\_groups / 2$$:
  1. $$eps = eps + .01$$
  2. return to step 2
4. else: remove the outlier segments from dataset and move on.

**Sample result of the algorithm:**
Red points correspond to the detected outlier segments, which are discarded before fitting the linear spline (or linear regression).

![DBScan on set 9: two outlier segments](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555078209198_Screen+Shot+2019-04-12+at+6.40.01+PM.png)
![DBScan on set 1: three outlier segments](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555078212216_Screen+Shot+2019-04-12+at+6.39.52+PM.png)


**Note:** It’s clear that the outlier detection must be the first phase of the algorithm after reading the input (before choosing the predictor, number of knots and …)

**Detecting outliers using linear regression**
Another idea was to detect outliers according to the [**high leverage points**](https://en.wikipedia.org/wiki/Leverage_(statistics)) and [**outliers**](https://stattrek.com/regression/influential-points.aspx) corresponding to a simple linear regression fit on the input dataset, which didn’t work so well after the implementation and lead to lower training score rather than the DBScan method, and hence was not used. ****

# 4. Implementation and sample results
----------

The implementation of my proposed method is available on GitHub: [AveragingGPSSegments](https://github.com/mohamad-amin/AveragingGPSSegments)
Here are some useful methods that are implemented and can be used: (assuming you are in the project directory)

## Reading the input set and converting to tabular data
    source('functions/read_segments.R')
    dataset = read_segment('training_data/0.csv')
    print(head(dataset))
![](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555074088677_Screen+Shot+2019-04-12+at+5.30.43+PM.png)

## Plotting the result of algorithm on each set:
    source('functions/draw_solution.R')
    draw_route(1)
![](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555078659941_Screen+Shot+2019-04-12+at+6.47.28+PM.png)


Getting complete output corresponding to the training data in `training_data` folder:

    source('functions/save_solution.R')
    save_predicted_segments('result.txt')

And then uploading the result on the training webpage:

![Sample results of the proposed method](https://paper-attachments.dropbox.com/s_63F395F72FDAF53A901DC382D62D1CCA12200EEA567CED160C47ED9734A7EACD_1555075375246_Screen+Shot+2019-04-12+at+5.52.42+PM.png)


The current accuracy achieved by the implementation is 66.32%. Although I think it’s already not that bad, noticing that the data has a high amount of irreducible error; I believe the accuracy can be enhanced by some better approximations of the outliers, starting points and the end points.

# 5. Conclusion
----------

As the previous section suggests, the proposed method has a good rate of training error and is performing nicely, noticing the huge rate of irreducible error of the data. We used a combination of linear spline and linear regression models for predicting the approximated true road segments, with some tricks for choosing the starting points, ending points and using DBScan for detecting outliers.

Clearly, the proposed method on using DBScan algorithm is too slow, as it may repeat a couple of times.
Also, there are many points of improvement in the method for future work:

1. Smarter outlier segment detection:
  1. Using other outlier detection methods, like using kNN for it.
  2. Optimizing the $$eps$$ guess on DBScan at the beginning, according to other factors in the dataset, like the number of segments, the number of points in each segment and …
2. Smarter choice of the begin and end points
3. Smarter choice of knots used in linear spline, and tradeoff between using linear spline and linear regression
# 6. Citations
----------

I think this method is a novel approach for solving this problem, and haven’t seen anyone using this approach for doing map-construction. However, I think I should cite the papers introducing “Linear Splines” and “DBScan” algorithms, as they’re the backbone of this method:

- **Linear Spline:** https://www.tandfonline.com/doi/abs/10.1080/01621459.1976.10481540
- **DBScan:** https://www.aaai.org/Papers/KDD/1996/KDD96-037.pdf

