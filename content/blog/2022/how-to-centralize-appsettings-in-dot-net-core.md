+++
title = "How to centrailize appsettings.json for ASP.NET Core & Entity Framework Core"
date = "2022-09-21T02:19:41+04:00"
author = "Alvan Rahimli"
authorTwitter = "alvan_rahim"
cover = ""
tags = ["tutorial", "dotnet"]
keywords = ["dotnet", "guide"]
description = "How to centrailize appsettings.json in ASP.NET Core & Entity Framework Core"
showFullContent = false
readingTime = true
draft = false
+++

By the end of this post, we will have centralized configuration files and necessary codes to ensure all our services will work from same configuration files and EntityFrameworkCore is able to add/remove migrations, update/drop database using those centralized configuration files.

## Why do we need to centralize?
While working on somewhat complex web services (like microservices, etc.) we often work on multiple projects which require some kind of configuration. 

In .NET Core apps, by default, these configs are handled with `appsettings.json` and `appsettings.{env}.json` files, which are created per project. This is fine until we get to the need of copy/pasting same config thing to all config files. 

The best way to solve this is having only one config file and sharing it accross solution.

## What will we get?
After following instructions below, we will have a solution structure like this:

```
MyAppRoot/
|-- MyApp.sln
|-- src/
|   |-- Config/
|   |   |-- appsettings.json (original)
|   |   |-- appsettings.Development.json (original)
|   |-- Services/
|   |   |-- MyApp.Api/
|   |   |   |-- Controllers/
|   |   |   |-- Models/
|   |   |   |-- appsettings.json (link to original)
|   |   |   |-- appsettings.Development.json (link to original)
|   |   |   |-- MyApp.Api.csproj
|   |   |-- MyApp.Admin/
|   |   |   |-- Pages/
|   |   |   |-- Models/
|   |   |   |-- appsettings.json (link to original)
|   |   |   |-- appsettings.Development.json (link to original)
|   |   |   |-- MyApp.Admin.csproj
|   |-- Shared/
|   |   |-- MyApp.Domain
|   |   |   |-- Data/
|   |   |   |   |-- MyAppDbContext.cs
|   |   |   |   |-- MyAppDbContextDesignTimeFactory.cs
|   |   |   |-- Models/
|   |   |   |-- appsettings.json (link to original)
|   |   |   |-- appsettings.Development.json (link to original)
|   |   |   |-- MyApp.Domain.csproj
```

## Steps to get result:
### 1. Creating solution's folder structure
- Create empty solution
  - `dotnet new sln -o MyApp`
- Create folders
  - `mkdir -P src/Config`
  - `mkdir -P src/Services`
  - `mkdir -P src/Shared`
  - (`-P` argument enforces to create parent directories if they don't exist)
- Create projects
  - `dotnet new webapi -o src/Services/MyApp.Api`
  - `dotnet new webapp -o src/Services/MyApp.Admin`
  - `dotnet new classlib -o src/Shared/MyApp.Domain`
- Add projects to solution
  - (unix): `dotnet sln MyApp.sln add **/*.csproj`
  - (windows): `dotnet sln MyApp.sln add (ls -r **/*.csproj)`
- Remove all config files from projects
  - `rm .\src\Services\*\*.json`
- Create new config files
  - (unix): `touch src/Config/appsettings.json`
  - (windows): `New-Item src\Config\appsettings.json`

### 2. Adding links to projects
#### Using an IDE like JetBrains Rider or Visual Studio:
Simply, right-click to project and select `Add > Existing item`. Find the config files under `src/Config` and add them to project. Note that, we don't won't to copy them, instead we want to add links to project. 

_In Rider, small dialog box appears and asks if it should copy or link files._

Now, we need to configure files to be copied to output folder. For this, in Rider, right-click to linked file (link in desied project) and go to `Properties`, then select `Copy to output` option.

#### Doing manually
To do it manually, add these lines to `.csproj` file of every project.

```xml
<ItemGroup>
  <Content Include="..\..\Config\*.*" LinkBase="\">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
  </Content>
  <Content Update="..\..\Config\appsettings.Development.json">
    <Link>appsettings.Development.json</Link>
  </Content>
  <Content Update="..\..\Config\appsettings.json">
     <Link>appsettings.json</Link>
  </Content>
</ItemGroup>
```

These lines are pretty self-explanatory:

Lines 2-4 we copy config files to output folder of project. (`bin/Debug/net6.0/`) `LinkBase` attribute specifies name of folder to copy in. For example, in `LinkBase="cfg\"` case, files will be copied to `bin/Debug/net6.0/cfg`.

Lines 5-7 and 8-10 are adding config files to projects as links.

### 3. Making app read Configuration from output folder:
This is last step. By default, ASP.NET Core tries to read `appsettings.json` file from project's root directory, which is, in our case, `src/Services/MyApp.Api`. To change this behavior, we just need to add these lines to `Program.cs`:

```csharp
builder.Host.ConfigureAppConfiguration((hostingContext, config) =>
{
    var env = hostingContext.HostingEnvironment;

    var path = env.ContentRootPath;
    if (env.IsDevelopment())
    {
        path = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
    }

    config.SetBasePath(path);
    config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
        .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true);
    config.AddEnvironmentVariables();
});
```

For these, we'll need to add following NuGet packages to out project:

- `Microsoft.Extensions.Configuration`
- `Microsoft.Extensions.Configuration.FileExtensions`
- `Microsoft.Extensions.Configuration.Json`

To make things tidy, we can create an extension method like this:

```csharp
public static class HostBuilderExtensions
{
    public static void ConfigureCentralizedConfiguration(this ConfigureHostBuilder host)
    {
        host.ConfigureAppConfiguration((hostingContext, config) =>
        {
            // Add here the code above
        }
    }
}
```

And use it like:

```csharp
builder.Host.ConfigureCentralizedConfiguration();
```

## By doing all of these, we are able to use centralized configuration files from all of our services.

## But:
EntityFrameworkCore won't work with these configs even if we've added links to `MyApp.Domain` project. We need to write custom `DbContextDesignTimeFactory` to be able to read our custom config. This code will also make it easier to use `dotnet-ef` tools, as it won't need other startup project to get DbContext instance.

It is easy: Add this file to `MyApp.Domain` project:

```csharp
public class MyAppDbContextDesignTimeFactory : IDesignTimeDbContextFactory<MyAppDbContext>
{
    public MyAppDbContext CreateDbContext(string[] args)
    {
        var env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development";
        var config = new ConfigurationBuilder()
            .SetBasePath(Path.Join(Directory.GetCurrentDirectory(), @"..\..\Config\"))
            .AddJsonFile("appsettings.json")
            .AddJsonFile($"appsettings.{env}.json")
            .Build();

        var builder = new DbContextOptionsBuilder<MyAppDbContext>()
            .UseNpgsql(config.GetConnectionString("Default"));
        return new MyAppDbContext(builder.Options);
    }
}
```

This is a class that implements `IDesignTimeDbContextFactory<MyAppDbContext>` and we don't need to reference it somewhere. `dotnet ef` will find it itself.

As last step, we need to add `Microsoft.EntityFrameworkCore.Design` NuGet package to our project.

## Finally!
Well, now our setup is ready. I may have missed some steps but I assume you'll be able to fill those gaps, as you should have decent level of .NET experience to be in need of smth like this.

Now, you can (in **project root**): `dotnet ef migrations add Initial` without needing any startup project (implementation of `IDesignTimeDbContextFactory<>` will provide DbContext instance)

***

## Thanks for reading this far :)
If you have any suggestions, feel free to contact me via my email: "alvan @ [rahim.li]" (remove spaces, square brackets and quotes)

## Now, music recommendations!
- [Unchain My Heart - Rita Payes](https://youtu.be/EkfxnJQ3omA)
- [Since You've Been Gone - Rita Payes](https://youtu.be/Ut_Do7ZeXOE)

Wrote with 💖, by me 😊