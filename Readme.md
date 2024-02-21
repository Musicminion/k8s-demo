# 一些k8s的demo

建议的`apply`的顺序：
- 如果有数据库，首先apply数据库的部分
- 对于每个应用程序具体的来说顺序依次是：`PersistentVolumeClaim`,`Deployment`,`Service`

