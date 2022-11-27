+++
title = "Non-Functional Requirements"
author = "Alvan Rahimli"
date = "2021-09-03T14:19:49Z"
draft = false
+++

Non-functional requirements are, but not limited to:
- Performance
- Load
- Data volume
- Concurrent users
- SLA & etc.

## Performance
System must be fast. But fast is relative term. If there is an end user fast means requests taking less than 1 sec. On the other side if we are working B2B, fast can mean less than 100ms.

### Latency
How much time does it take to perform a single task?

### Throughput
How many tasks can be performed in a given time unit?

### Latency VS Throughput
|Type		|Duration|
|---|---|
|Latency	|1second|
|Throughput	|- Well designed app: > 1000
|			|- Badly designed app: < 60

## Load
Quantity of work we can perform without crushing. (It depends on application type)
E.g: WebAPI -> Number of concurrent requests we can handle without crashing.

### Load VS Throughput
|Type			|Value
|---|---
|Throughput		|100 requests/sec|
|Load			|500 requests without crashing|
_For e-commerce app it can be ~200 concurrent request, but system must be available on Black Fridays. So, we must be ready for ~2000 concurrent requests._

## Data Volume
- How much data the system will accumulate over time
- Helps with:
	- Deciding on Database type
	- Designing queries
	- Storage planning

- Two aspects:
	- Data required on "Day One"
	- Data growth over time

## Concurrent users
- How many users will use system simultaniously

### Concurrent users VS Load
|Key	|Value
|---|---
|Concurrent Users	| Including "Dead times"
|Load				| Actual requests

For example, user requests for all products in category. Service handles request. After this for 5 minute user will be looking at this data. This duration is counted as __"Dead Time"__ and appropriate user is included in __concurrent users__.  
For average system, `Concurrent = Load x 10`

## SLA (Service Level Agreement)
Required uptime for the system  

_Cloud providers are mostly competing in this field. For example, SLA for Azure Cosmos DB is notes as 99.99% This means less than an hour per year:_
```
24 * 365 = 8760 hrs/year
8760 * 99.99% = 8759.12
________________________
8760 - 8759.12 = 0.88 hrs/year
```

## Conclusion
- Define what the system will have to deal with
	- Performance, SLA, Load and etc.
- Client won't be able to define them
- Never begin working without Non-Functional requirements defined
