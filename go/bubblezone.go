package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"runtime/debug"
	"sync"
	"unsafe"
	zone "github.com/lrstanley/bubblezone"
)

var (
	nextID   uint64 = 1
	nextIDMu sync.Mutex
)

func getNextID() uint64 {
	nextIDMu.Lock()
	defer nextIDMu.Unlock()
	id := nextID
	nextID++
	return id
}

var (
	managers   = make(map[uint64]*zone.Manager)
	managersMu sync.RWMutex
)

func allocManager(m *zone.Manager) uint64 {
	managersMu.Lock()
	defer managersMu.Unlock()
	id := getNextID()
	managers[id] = m
	return id
}

func getManager(id uint64) *zone.Manager {
	managersMu.RLock()
	defer managersMu.RUnlock()
	return managers[id]
}

var (
	zoneInfos   = make(map[uint64]*zone.ZoneInfo)
	zoneInfosMu sync.RWMutex
)

func allocZoneInfo(z *zone.ZoneInfo) uint64 {
	if z == nil {
		return 0
	}

	zoneInfosMu.Lock()
	defer zoneInfosMu.Unlock()
	id := getNextID()
	zoneInfos[id] = z

	return id
}

func getZoneInfo(id uint64) *zone.ZoneInfo {
	zoneInfosMu.RLock()
	defer zoneInfosMu.RUnlock()
	return zoneInfos[id]
}

//export bubblezone_free
func bubblezone_free(pointer *C.char) {
	C.free(unsafe.Pointer(pointer))
}

//export bubblezone_upstream_version
func bubblezone_upstream_version() *C.char {
	info, ok := debug.ReadBuildInfo()
	if !ok {
		return C.CString("unknown")
	}

	for _, dep := range info.Deps {
		if dep.Path == "github.com/lrstanley/bubblezone" {
			return C.CString(dep.Version)
		}
	}

	return C.CString("unknown")
}

//export bubblezone_new_manager
func bubblezone_new_manager() C.ulonglong {
	m := zone.New()
	return C.ulonglong(allocManager(m))
}

//export bubblezone_free_manager
func bubblezone_free_manager(id C.ulonglong) {
	managersMu.Lock()

	defer managersMu.Unlock()

	if m, ok := managers[uint64(id)]; ok {
		m.Close()
		delete(managers, uint64(id))
	}
}

//export bubblezone_manager_close
func bubblezone_manager_close(id C.ulonglong) {
	m := getManager(uint64(id))

	if m != nil {
		m.Close()
	}
}

//export bubblezone_manager_set_enabled
func bubblezone_manager_set_enabled(id C.ulonglong, enabled C.int) {
	m := getManager(uint64(id))

	if m != nil {
		m.SetEnabled(enabled != 0)
	}
}

//export bubblezone_manager_enabled
func bubblezone_manager_enabled(id C.ulonglong) C.int {
	m := getManager(uint64(id))

	if m != nil && m.Enabled() {
		return 1
	}

	return 0
}

//export bubblezone_manager_new_prefix
func bubblezone_manager_new_prefix(id C.ulonglong) *C.char {
	m := getManager(uint64(id))

	if m == nil {
		return C.CString("")
	}

	return C.CString(m.NewPrefix())
}

//export bubblezone_manager_mark
func bubblezone_manager_mark(id C.ulonglong, zoneID *C.char, text *C.char) *C.char {
	m := getManager(uint64(id))

	if m == nil {
		return C.CString(C.GoString(text))
	}

	result := m.Mark(C.GoString(zoneID), C.GoString(text))

	return C.CString(result)
}

//export bubblezone_manager_clear
func bubblezone_manager_clear(id C.ulonglong, zoneID *C.char) {
	m := getManager(uint64(id))

	if m != nil {
		m.Clear(C.GoString(zoneID))
	}
}

//export bubblezone_manager_get
func bubblezone_manager_get(id C.ulonglong, zoneID *C.char) C.ulonglong {
	m := getManager(uint64(id))

	if m == nil {
		return 0
	}

	z := m.Get(C.GoString(zoneID))

	return C.ulonglong(allocZoneInfo(z))
}

//export bubblezone_manager_scan
func bubblezone_manager_scan(id C.ulonglong, text *C.char) *C.char {
	m := getManager(uint64(id))

	if m == nil {
		return C.CString(C.GoString(text))
	}

	result := m.Scan(C.GoString(text))

	return C.CString(result)
}

//export bubblezone_free_zone_info
func bubblezone_free_zone_info(id C.ulonglong) {
	zoneInfosMu.Lock()
	defer zoneInfosMu.Unlock()
	delete(zoneInfos, uint64(id))
}

//export bubblezone_zone_info_start_x
func bubblezone_zone_info_start_x(id C.ulonglong) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil {
		return 0
	}

	return C.int(z.StartX)
}

//export bubblezone_zone_info_start_y
func bubblezone_zone_info_start_y(id C.ulonglong) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil {
		return 0
	}

	return C.int(z.StartY)
}

//export bubblezone_zone_info_end_x
func bubblezone_zone_info_end_x(id C.ulonglong) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil {
		return 0
	}

	return C.int(z.EndX)
}

//export bubblezone_zone_info_end_y
func bubblezone_zone_info_end_y(id C.ulonglong) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil {
		return 0
	}

	return C.int(z.EndY)
}

//export bubblezone_zone_info_is_zero
func bubblezone_zone_info_is_zero(id C.ulonglong) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil || z.IsZero() {
		return 1
	}

	return 0
}

//export bubblezone_zone_info_in_bounds
func bubblezone_zone_info_in_bounds(id C.ulonglong, x C.int, y C.int) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil {
		return 0
	}

	if z.IsZero() {
		return 0
	}

	if z.StartX > z.EndX || z.StartY > z.EndY {
		return 0
	}

	if int(x) < z.StartX || int(y) < z.StartY {
		return 0
	}

	if int(x) > z.EndX || int(y) > z.EndY {
		return 0
	}

	return 1
}

//export bubblezone_zone_info_pos
func bubblezone_zone_info_pos(id C.ulonglong, x C.int, y C.int, outX *C.int, outY *C.int) C.int {
	z := getZoneInfo(uint64(id))

	if z == nil {
		*outX = -1
		*outY = -1
		return 0
	}

	if z.IsZero() {
		*outX = -1
		*outY = -1
		return 0
	}

	inBounds := bubblezone_zone_info_in_bounds(id, x, y)

	if inBounds == 0 {
		*outX = -1
		*outY = -1
		return 0
	}

	*outX = C.int(int(x) - z.StartX)
	*outY = C.int(int(y) - z.StartY)

	return 1
}

//export bubblezone_new_global
func bubblezone_new_global() {
	zone.NewGlobal()
}

//export bubblezone_global_close
func bubblezone_global_close() {
	zone.Close()
}

//export bubblezone_global_set_enabled
func bubblezone_global_set_enabled(enabled C.int) {
	zone.SetEnabled(enabled != 0)
}

//export bubblezone_global_enabled
func bubblezone_global_enabled() C.int {
	if zone.Enabled() {
		return 1
	}

	return 0
}

//export bubblezone_global_new_prefix
func bubblezone_global_new_prefix() *C.char {
	return C.CString(zone.NewPrefix())
}

//export bubblezone_global_mark
func bubblezone_global_mark(zoneID *C.char, text *C.char) *C.char {
	result := zone.Mark(C.GoString(zoneID), C.GoString(text))
	return C.CString(result)
}

//export bubblezone_global_clear
func bubblezone_global_clear(zoneID *C.char) {
	zone.Clear(C.GoString(zoneID))
}

//export bubblezone_global_get
func bubblezone_global_get(zoneID *C.char) C.ulonglong {
	z := zone.Get(C.GoString(zoneID))
	return C.ulonglong(allocZoneInfo(z))
}

//export bubblezone_global_scan
func bubblezone_global_scan(text *C.char) *C.char {
	result := zone.Scan(C.GoString(text))
	return C.CString(result)
}

func main() {}
