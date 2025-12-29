#include "extension.h"

static void manager_free(void *pointer) {
  bubblezone_manager_t *manager = (bubblezone_manager_t *)pointer;

  if (manager->handle != 0) {
    bubblezone_free_manager(manager->handle);
  }

  xfree(manager);
}

static size_t manager_memsize(const void *pointer) {
  return sizeof(bubblezone_manager_t);
}

const rb_data_type_t manager_type = {
  .wrap_struct_name = "Bubblezone::Manager",
  .function = {
    .dmark = NULL,
    .dfree = manager_free,
    .dsize = manager_memsize,
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE manager_alloc(VALUE klass) {
  bubblezone_manager_t *manager = ALLOC(bubblezone_manager_t);
  manager->handle = bubblezone_new_manager();
  return TypedData_Wrap_Struct(klass, &manager_type, manager);
}

VALUE manager_wrap(VALUE klass, unsigned long long handle) {
  bubblezone_manager_t *manager = ALLOC(bubblezone_manager_t);
  manager->handle = handle;
  return TypedData_Wrap_Struct(klass, &manager_type, manager);
}

static VALUE manager_initialize(VALUE self) {
  return self;
}

static VALUE manager_close(VALUE self) {
  GET_MANAGER(self, manager);
  bubblezone_manager_close(manager->handle);
  return Qnil;
}

static VALUE manager_set_enabled(VALUE self, VALUE enabled) {
  GET_MANAGER(self, manager);
  bubblezone_manager_set_enabled(manager->handle, RTEST(enabled) ? 1 : 0);
  return enabled;
}

static VALUE manager_enabled(VALUE self) {
  GET_MANAGER(self, manager);
  return bubblezone_manager_enabled(manager->handle) ? Qtrue : Qfalse;
}

static VALUE manager_new_prefix(VALUE self) {
  GET_MANAGER(self, manager);

  char *prefix = bubblezone_manager_new_prefix(manager->handle);
  VALUE rb_prefix = rb_utf8_str_new_cstr(prefix);
  bubblezone_free(prefix);

  return rb_prefix;
}

static VALUE manager_mark(VALUE self, VALUE zone_id, VALUE text) {
  GET_MANAGER(self, manager);
  Check_Type(zone_id, T_STRING);
  Check_Type(text, T_STRING);

  char *result = bubblezone_manager_mark(manager->handle, StringValueCStr(zone_id), StringValueCStr(text));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  bubblezone_free(result);

  return rb_result;
}

static VALUE manager_clear(VALUE self, VALUE zone_id) {
  GET_MANAGER(self, manager);
  Check_Type(zone_id, T_STRING);
  bubblezone_manager_clear(manager->handle, StringValueCStr(zone_id));
  return Qnil;
}

static VALUE manager_get(VALUE self, VALUE zone_id) {
  GET_MANAGER(self, manager);
  Check_Type(zone_id, T_STRING);

  unsigned long long handle = bubblezone_manager_get(manager->handle, StringValueCStr(zone_id));

  if (handle == 0) {
    return Qnil;
  }

  return zone_info_wrap(cZoneInfo, handle);
}

static VALUE manager_scan(VALUE self, VALUE text) {
  GET_MANAGER(self, manager);
  Check_Type(text, T_STRING);

  char *result = bubblezone_manager_scan(manager->handle, StringValueCStr(text));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  bubblezone_free(result);

  return rb_result;
}

void Init_bubblezone_manager(void) {
  cManager = rb_define_class_under(mBubblezone, "Manager", rb_cObject);

  rb_define_alloc_func(cManager, manager_alloc);

  rb_define_method(cManager, "initialize", manager_initialize, 0);
  rb_define_method(cManager, "close", manager_close, 0);
  rb_define_method(cManager, "enabled=", manager_set_enabled, 1);
  rb_define_method(cManager, "enabled?", manager_enabled, 0);
  rb_define_method(cManager, "new_prefix", manager_new_prefix, 0);
  rb_define_method(cManager, "mark", manager_mark, 2);
  rb_define_method(cManager, "clear", manager_clear, 1);
  rb_define_method(cManager, "get", manager_get, 1);
  rb_define_method(cManager, "scan", manager_scan, 1);
}
