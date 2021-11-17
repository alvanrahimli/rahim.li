+++
title = "Learning Asynchronous Programming - Notes"
date = "2021-11-17T20:45:34+04:00"
author = "Alvan Rahimli"
authorTwitter = "" #do not include @
cover = ""
tags = ["daily", "learning"]
keywords = ["async", "await", "dotnet", "task", "concurrency", "parallelism"]
description = "My notes and whole learning curve of asynchronous programming in .NET"
showFullContent = false
readingTime = true
+++

# 🚀 What are the incentives?
It is my third week working as a Software Developer at a [company](https://staffwerke.de) which I have been given only one task so far. Task's details are protected under NDA, so, I can't tell what exactly it was. But I'm having problems with it so, it turns out, I have to learn more about this "Async programming". 

---
# 🎯 What are the goals for today?
Well, I hope for better understanding of `Task` :D

---
# 🏁 Let's go!
## ⚠️ Disclaimer
This post is not a comprehensive guide to this topic. These are just notes I take while researching and learning this topic.

## Task VS Thread
It turns out, differentiating these concepts is kinda the key point. `Task` has nothing to do with `Thread`.
Basically, 

- `Task` just represents a work that is planned to be executed.
  - Well, thanks to my [friend](https://themisir.com) for pointing out, it is not exactly like this. Technically, Task is returned **after** execution is started. So it represents work that is already executing.
- `Thread` is the execution itself.

Yes, it gets interesting. I was told `Task` is lightweight `Thread`. Looks like I have been tricked a bit :D

![We have been tricked](/images/shared/we-have-been-tricked.png#center)

### Task:
Task represents a work that needs to be done. It can be completed right now or after some time. 

Task can be completed, or faulted. It is it's all duty - **keeping track whether a work is completed or not**.
Only if some Task is not faulted during execution, meaning it completed, next Task is scheduled.

The thing that controls this task scheduling is called, very intuitively, [`TaskScheduler`](#task-scheduler). 

### Thread:
Threads are very different concept. It represents execution of code. It keeps track of what is executing and where is it executing? 
Threads has [`SynchronizationContext`](#synchronization-context) associated which is used to communicate between different types of threads.

**Threads execute tasks scheduled by a TaskScheduler**

---
## What exactly is Await?
Let's assume we have a program that takes long time to finish. Most of the times this will be some I/O bound code. This kind of operations does not require that much CPU while waiting for third party "thing". For example, fetching string from a server with `HttpClient`.

```csharp
public async Task<string> ReadStringFromServer(string url)
{
    var request = await _httpClient.GetAsync(url);
    var finalString = await request.Content.ReadAsStringAsync();
    return finalString;
}
```

The above code demonstrates proper way of fetching data. But why is so?  
As we know, using network is costly operation, as we have to wait for other server's response. But in this case, we are not exactly waiting for that server's response. Instead, we are using that precious time for handling other requests or completing other Task. 

### But how this is possible?
Of course, because of (not only) that `async`/`await` keywords. Actually, as we are diving deeper than usual, it is not those keywords doing magic. It is `ContinueWith`/`Unwrap` APIs from `Task` class. Basically, `async`&`await` are just syntactic sugar for following code:

```csharp
public async Task<string> ReadStringFromServer(string url)
{
    var requestTask = HttpClient.GetAsync(url);
    var readStringTask = request.ContinueWith(http => 
        http.Result.Content.ReadAsStringAsync());
    return download.Unwrap();
}
```

Here, what `TaskScheduler` does is: 
- Scheduling `requestTask`
- If `requestTask` completes
  - Scheduling `readStringTask`

So, every Task we use is added to a queue and is executed one-by-one. As we stated earlier, this is all done by `TaskScheduler`.

*By far, all we did was for sake of optimizing time for execution.

## About DeadLock
DeadLock is when our executing thread is suspended and waiting for some work to be complete, meaning this particular Thread is allocated just for some particular Task. This is exactly what we are trying to avoid, as Threads are expensive and very limited.

Let's consider following code. Here, `ReadStringFromServer` is sync method, meaning caller thread will be blocked and waiting for some work to complete.

```csharp
public string ReadStringFromServer(string url)
{
    // Never NEVER never ever! use task.Result
    var request = _httpClient.GetAsync(url).Result;
    var finalString = request.Content.ReadAsStringAsync().Result;
    return finalString;
}
```

What is happening here is:
- At some point in execution of `GetAsync` it will need to wait for OS's networking API's response
- This is where it will return Task, representing this incomplete work.
  - *Here, we could schedule it for later accessing, instead:
- We use `.Result` property which blocks current thread and waits for completion.
  - *This ruins purpose of async code

But in actuality this code depends on context (where method is called). And problem really is this:
- If context is **UI thread**, whole app will be **deadlocked**.
- If context is **ThreadPool thread**, high load will drain all pool and lead to deadlock.
- If context is **dedicated thread** (e.g: `Main` method) it won't make any difference, as thread does not have to handle other tasks.

Here, third case gives us very good chance to make call to `async` function from `sync` one. For example, while working from UI thread, if we allocate separate thread to just this function, it won't cause huge problems to us.

```csharp
public string ReadStringFromServer(string url)
{
    Task.Run(async () => 
    {
        var request = await _httpClient.GetAsync(url);
        var finalString = await request.Content.ReadAsStringAsync();
        return finalString;
    }).Result;
}
```
What below code (specifically `Task.Run`) does is forcing task to execute in Thread Pool thread. So, this code is okay when called from a thread **other than** Thread Pool.

Well, we still have opportunity to make this code worst. Let's try smth like this:

```csharp
public string ReadStringFromServer(string url)
{
    Task.Run(() => 
    {
        var request = _httpClient.GetAsync(url).Result;
        var finalString = request.Content.ReadAsStringAsync().Result;
        return finalString;
    }).Result;
}
```
This is where the disaster happens. 
- Call to `Task.Run(...).Result` blocks caller thread.
- Call to `_httpClient.GetAsync(url).Result` blocks Thread Pool thread.

The code below will deadlock application, no matter what context we are calling it from.

### 📌 I will continue writing on this topic as I learn

# 📚 References:
- [MS Docs](https://docs.microsoft.com/en-us/dotnet/csharp/async)
- [Understanding Async, Avoiding Deadlocks in C#](https://medium.com/rubrikkgroup/understanding-async-avoiding-deadlocks-e41f8f2c6f5d)
  - Code samples and generally this article itself is based on this resource. 
- [Async in depth](https://docs.microsoft.com/en-us/dotnet/standard/async-in-depth)