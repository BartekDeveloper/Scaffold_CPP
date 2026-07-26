#include "interface.hpp"

#include <gtest/gtest.h>

namespace {

    TEST(ScaffoldTests, BuildGreetingFormatsTheSubject) {
        EXPECT_EQ(MyLib::Hello(), "World");
    }

} // namespace
