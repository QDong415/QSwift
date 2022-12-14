//    MIT License
//
//    Copyright (c) 2020 ๆขๅคง็บข
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


// ๐๐๐๐๐๐๐๐๐๐๐๐๐๐๐๐
// ๆๅผๅฎ่กจ็คบใ ๅฏ็จๅๅญๆณๆผ็ๆง ใ
#define __AUTO_MEMORY_LEAKS_FINDER_ENABLED__
// ๐๐๐๐๐๐๐๐๐๐๐๐๐๐๐๐๐

#ifdef __AUTO_MEMORY_LEAKS_FINDER_ENABLED__

#import "AMMemoryLeakModel.h"
#import "AMViewMemoryLeakModel.h"

typedef void(^AMLeakCallback)(NSArray <AMMemoryLeakModel *> * _Nonnull controllerMemoryLeakModels,
                              NSArray <AMViewMemoryLeakModel *> * _Nonnull viewMemoryLeakModels);

typedef void(^AMLVCPathCallback)(NSArray <AMVCPathModel *> * _Nonnull all, AMVCPathModel* _Nonnull current);

@interface AMLeaksFinder : NSObject

/// vc ๆไฝ่ทฏๅพ
@property (class, readonly) NSArray <AMVCPathModel *> *currentAllVCPathModels;

/// vc ๆณๆผๆฐๆฎ
@property (class, readonly) NSArray <AMMemoryLeakModel *> *leakVCModelArray;

/// view ๆณๆผๆฐๆฎ
@property (class, readonly) NSArray <AMViewMemoryLeakModel *> *leakViewModelArray;

/// ๆทปๅ?ๆณๆผๆฐๆฎๅ่ฐ
/// @param callback block
+ (void)addLeakCallback:(nonnull AMLeakCallback)callback;

/// ๆงๅถๅจ่ทฏๅพๅๅๅ่ฐ
/// @param callback block
+ (void)addVCPathChangedCallback:(nonnull AMLVCPathCallback)callback;

+ (nonnull NSArray <AMLeakCallback> *)callbacks;
+ (nonnull NSArray <AMLVCPathCallback> *)vcPathCallbacks;

// controller ๆณๆผ็ฝๅๅ, ไป็จไบใๆณๆผๆฐๆฎๅ่ฐ็่ฟๆปคใ,ใๆณๆผๆฐๆฎๅฎๆถ UI ็ถๆใๆๆ?ๆญค่ฎกๅ
@property (class) NSSet <NSString *> *controllerWhitelistClassNameSet;
// view ๆณๆผ็ฝๅๅ, ไป็จไบใๆณๆผๆฐๆฎๅ่ฐ็่ฟๆปคใ, ใๆณๆผๆฐๆฎๅฎๆถ UI ็ถๆใๆๆ?ๆญค่ฎกๅ
@property (class) NSSet <NSString *> *viewWhitelistClassNameSet;

@end

#endif
