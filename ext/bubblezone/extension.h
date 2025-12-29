#ifndef BUBBLEZONE_EXTENSION_H
#define BUBBLEZONE_EXTENSION_H

#include <ruby.h>
#include "libbubblezone.h"

extern VALUE mBubblezone;
extern VALUE cManager;
extern VALUE cZoneInfo;

typedef struct {
  unsigned long long handle;
} bubblezone_manager_t;

typedef struct {
  unsigned long long handle;
} bubblezone_zone_info_t;

#define GET_MANAGER(self, manager) \
  bubblezone_manager_t *manager; \
  TypedData_Get_Struct(self, bubblezone_manager_t, &manager_type, manager)

#define GET_ZONE_INFO(self, zone_info) \
  bubblezone_zone_info_t *zone_info; \
  TypedData_Get_Struct(self, bubblezone_zone_info_t, &zone_info_type, zone_info)

extern const rb_data_type_t manager_type;
extern const rb_data_type_t zone_info_type;

VALUE manager_wrap(VALUE klass, unsigned long long handle);
VALUE zone_info_wrap(VALUE klass, unsigned long long handle);

void Init_bubblezone_manager(void);
void Init_bubblezone_zone_info(void);

#endif
