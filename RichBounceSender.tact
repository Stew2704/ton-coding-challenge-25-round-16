// RichBounceSender.tact
import "@stdlib/ownable";

// 包含发送给 B 的消息结构
message MsgToB {
    queryId: Int;
    data: Slice;
}

contract RichBounceSender with Ownable {
    
    // 存储合约 B 的地址
    bAddress: Address;

    // 部署时的初始化函数
    init(bAddress: Address) {
        self.bAddress = bAddress;
    }

    // 接收钱包发送的外部消息
    // 触发内部消息发送给合约 B
    receive(msg: MsgToB) {
        // 检查所有权 (可选，但推荐)
        require(self.owner == sender(), "Only owner can trigger send");
        
        // 发送一个可回弹 (bounceable) 的内部消息给合约 B
        // 使用 MsgToB 结构体，并带上 bounce flag (默认就是 bounceable)
        send(SendParameters{
            to: self.bAddress,
            value: 0, // 可以是任何值，但 RichBounce 需要足够的 Gas 才能返回
            mode: SendRemainingBalance + 128, // Mode 128 确保 Gas 转发和 RichBounce 机制
            body: MsgToB{
                queryId: msg.queryId,
                data: msg.data
            }.toCell()
        });
    }

    // 接收并处理 RichBounce 回弹消息
    // 这是任务的核心部分：合约 A 处理合约 B 的回弹
    bounced(body: Slice) {
        // RichBounce 消息体 (body) 包含原始消息体和 RichBounce 信息
        // 
        // 1. 记录回弹事件 (在实际应用中，可以在这里触发日志或状态更新)
        //    我们只需要检查 body 是否存在以确认接收
        
        let originalMsgCell: Cell = body.loadRef(); // 原始消息体通常在第一个引用中
        let originalMsg: MsgToB = originalMsgCell.asSlice().load();
        
        // 2. 状态更新示例 (这里我们只打印信息)
        // 实际应用中，可能会更新状态以标记发送失败或触发其他恢复逻辑
        
        // console("RichBounce received!");
        // console("Original Query ID: " + originalMsg.queryId.toString());
        // console("Sender has been notified of B's failure.");

        // 示例：更新一个状态变量来记录回弹次数
        // self.bounceCount = self.bounceCount + 1;
    }

    // 额外的接收器，允许设置所有者
    receive("Deploy") {
        self.owner = sender();
    }
    
    // 用于测试/部署的getter
    get fun b_address(): Address {
        return self.bAddress;
    }
}
