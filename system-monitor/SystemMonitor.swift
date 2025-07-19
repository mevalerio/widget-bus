
import Foundation
import IOKit

class SystemMonitor {

    private var prevCpuInfo: processor_info_array_t?
    private var numPrevCpuInfo: mach_msg_type_number_t = 0

    func getCPUUsage() -> Double {
        var totalUsage: Double = 0.0
        var cpuInfo, prevCpuInfo: processor_info_array_t?
        var numCpuInfo, numPrevCpuInfo: mach_msg_type_number_t = 0
        let info = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCpuInfo, &cpuInfo)
        if info == KERN_SUCCESS {
            let cpuInfo = cpuInfo!
            let numCpuInfo = numCpuInfo
            if let prevCpuInfo = prevCpuInfo {
                for i in 0..<Int(numCpuInfo) {
                    let inUse = cpuInfo[i] - prevCpuInfo[i]
                    let total = cpuInfo[i] + prevCpuInfo[i]
                    totalUsage += Double(inUse) / Double(total)
                }
            }
            self.prevCpuInfo = cpuInfo
            self.numPrevCpuInfo = numCpuInfo
        }
        return totalUsage
    }

    func getMemoryUsage() -> (free: Double, used: Double, total: Double) {
        var vmStats = vm_statistics64()
        var pageSize: vm_size_t = 0
        let host = mach_host_self()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let kernReturn = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(host, HOST_VM_INFO64, $0, &count)
            }
        }
        if kernReturn == KERN_SUCCESS {
            let free = Double(vmStats.free_count) * Double(pageSize)
            let active = Double(vmStats.active_count) * Double(pageSize)
            let inactive = Double(vmStats.inactive_count) * Double(pageSize)
            let wired = Double(vmStats.wire_count) * Double(pageSize)
            let speculative = Double(vmStats.speculative_count) * Double(pageSize)
            let purgeable = Double(vmStats.purgeable_count) * Double(pageSize)
            let used = active + inactive + wired + speculative + purgeable
            let total = free + used
            return (free / (1024*1024*1024), used / (1024*1024*1024), total / (1024*1024*1024))
        } else {
            return (0,0,0)
        }
    }

    func getGPUUsage() -> Double {
        var iterator: io_iterator_t = 0
        var totalUsage: Double = 0.0
        var count: Int = 0
        let result = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOAccelerator"), &iterator)
        if result == kIOReturnSuccess {
            var service = IOIteratorNext(iterator)
            while service != 0 {
                var dict: Unmanaged<CFMutableDictionary>?
                let serviceResult = IORegistryEntryCreateCFProperties(service, &dict, kCFAllocatorDefault, 0)
                if serviceResult == kIOReturnSuccess, let dict = dict {
                    let stats = dict.takeUnretainedValue() as! [String: Any]
                    if let performanceStatistics = stats["PerformanceStatistics"] as? [String: Any],
                       let utilization = performanceStatistics["GPU Core Utilization"] as? Double {
                        totalUsage += utilization
                        count += 1
                    }
                }
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            IOObjectRelease(iterator)
        }
        return count > 0 ? totalUsage / Double(count) : 0.0
    }
}
