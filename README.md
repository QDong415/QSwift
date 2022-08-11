
![列表界面](https://upload-images.jianshu.io/upload_images/26002059-7ec9ff698bb9c047.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 新IOS开发者容易犯下的错误：

- ❌ 工程中每个tableviewVC都有一个自己的xib
因为：浪费空间。新建VC要复制两个文件，还需要重新去拉xib和vc的tableview
- ✅  封装好BaseTableViewController，并且BaseTableViewController使用frame而不是xib。你用xib拉约束，可能加载时间为0.01秒，但是我用frame+viewDidLayoutSubView ，加载时间为0.005秒。
---

- ❌ 工程中主要界面使用StoryBoard。
缺点：
- 1、StoryBoard里vc太多的话，每次点开storyBoard会卡两秒，且他通留在左上角，你要找半天对应的vc在哪
- 2、多人合作容易触发git冲突，且storyBoard的git冲突很难解决
- 3、StoryBoard里修改一个vc的时候，如果不消息手滑动了别的vc的控件，git提交上去，也察觉不到问题
- 4、StoryBoard虽然可以在tableview里设置cell，但是这样的cell别的界面无法复用
- 5、需要反复的放大缩小
- ✅ 应该：简单的界面使用xib。子控件容易hide的界面、追求效率的界面 使用传统的frame
---

- ❌ Cell不规则的界面，他就不用了TableView，他用ScrollView。最后所有的控件都在一个非常庞大的xib里，且控件hidden的时候只能把约束拉到vc里，vc里一堆约束的全局变量
- ✅ 本库有个基于tableview的完美案例，一个cell占用一个文件+xib，完美解耦，大量减轻vc的负担
---

- ❌ 不加思索的引用第3方开源库
- - ✅ 引用第3方开源库前，先看一下他有没有+(void)load 方法和methodSwizzing方法。如果有，尽量不用这个库，或者你手动修改。评估他可能产生的影响
✅ 引用第3方开源库前，再看看他有没有pod别的库
---

- ❌ 不引入LeakFinder库
- ✅ debug模式下要使用内存泄漏检测库、fps、cpu检测库，直接有界面的那种
---

- ❌ 列表界面无emptyView和errorView，没有数据的时候就显示白板
- ✅ 就算UI图没做，程序员也应该做，基本的职业道德
---

- ❌ 无脑弹Loading框，下拉刷新也弹框，点赞也弹框
- ✅ 稍微像样一点的app都不会这样无脑弹框。只有特别重要且不高频的事件才弹框：比如登录注册事件。发表评论、发朋友圈、修改头像昵称，都不需要弹框，自己处理好error回调
---

- ❌ 下拉刷新、底部加载这种翻页TableView，page控制错误
案例：如果当前已经加装到第8页（page==8）然后滚到底部加载第9页，这时候手机网络断开了导致加载失败。然后手机网络恢复，然后再滚到底部去加载，这时候加载出来的是第10页数据。第9页数据丢失（无网络的时候去下拉刷新也容易出类似问题）
- ✅ 本案有个教科书级别的page处理案例
---

- ❌ xib拉约束，运行时候xcode报出一堆错误日志
- ✅ 需要的时候，请使用750优先级
---

- ❌ 不会使用estimatedHeightForRowAt做列表优化
- ✅ 本案有最佳使用案例
---

- ❌ 首次安装App，系统会弹出是否允许访问网络的弹框。弹框时候是无网络的。等用户点了确认要监听网络恢复
- ✅ 本案有最佳使用案例
---

- ❌ 请求网络的封装，还额外封装一层。即：VC -> 中间类的static方法拼接参数 -> 网络请求类拼接统一header -> 调用AF发出请求
- ✅ 中间类没有任何意义，你写的也累。且系统底层还需要额外走一程method_list 去寻找方法，再存入method_cache。
---

- ❌ 代码中用0xFFFFFF这种android的颜色码，然后再用一个颜色转化库去转换成IOS的颜色码
- ✅ 没有任何意义，还浪费代码执行时间，还是解耦的毒瘤
---

- ❌ 喜欢用全局变量
- ✅ 1、全局变量会让逻辑变的复杂混乱。全局变量越多，需要注意的点就越多。别人读起来也更困难，也更容易出bug
- ✅ 2、全局变量的生命周期是最长的，和vc的生命周期一致。会带来更多的内存消耗，也更容易引起内存泄漏问题
---

- ❌ 在layoutSubViews，viewDidLayoutSubViews里设置控件的约束
- ✅ 这两个方法回调非常频繁，比如手机回到home会触发vc4次viewDidLayoutSubViews。且约束根本不是这样用的
---

- ✅ Swift的block和Kotlin的回调闭包，允许我们可以省略回调值的类型。如果是系统的常见方法，可以省略。但是如果是自己写的方法，禁止省略回调值类型。
别人看不懂你的方法的回调值的类型是什么，你自己过一段时间也看不懂自己的代码的回调值是什么。可读性非常差

> 本库为了立一个标准开发的标杆。中级新手ios新建项目完全可以下载本库rename一下就行了，代码足够的规范、标准

[后续会一直更新，请给个star](https://github.com/QDong415/QSwift)

## Author：DQ  285275534@qq.com
我的其他开源库，给个Star鼓励我写更多好库：

[IOS Swift项目框架模版Demo，教科书级标准。轻量、规范、易懂、易移植、解耦](https://github.com/QDong415/QSwift)

[IOS 1:1完美仿微信聊天表情键盘](https://github.com/QDong415/QKeyboardEmotionView)

[IOS 自定义UIAlertController，支持弹出约束XibView、弹出ViewController](https://github.com/QDong415/QUIAlertController)

[IOS 封装每条Cell样式都不一致的UITableView，告别复杂的UITableViewDataSource](https://github.com/QDong415/QTableKit)

[IOS 仿快手直播界面加载中，顶部的滚动条状LoadingView](https://github.com/QDong415/QStripeAnimationLayer)

[IOS 基于个推+华为push的一整套完善的 IM聊天系统](https://github.com/QDong415/iTopicOCChat)

[Android 朋友圈列表Feed流的最优化方案，让你的RecyclerView从49帧 -> 57帧](https://github.com/QDong415/QFeed)

[Android 仿大众点评、仿小红书 下拉拖拽关闭Activity](https://github.com/QDong415/QDragClose)

[Android 仿快手直播间手画礼物，手绘礼物](https://github.com/QDong415/QDrawGift)

[Android 直播间聊天消息列表RecyclerView。一秒内收到几百条消息依然不卡顿](https://github.com/QDong415/QLiveMessageHelper)

[Android 仿快手直播界面加载中，顶部的滚动条状LoadingView](https://github.com/QDong415/QStripeView)

[Android Kotlin MVVM框架，全世界最优化的分页加载接口、最接地气的封装](https://github.com/QDong415/QKotlin)

[Android 基于个推+华为push的一整套完善的android IM聊天系统](https://github.com/QDong415/iTopicChat)