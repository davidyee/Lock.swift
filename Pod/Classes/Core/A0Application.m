// A0Application.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0Application.h"
#import "A0Strategy.h"

@interface A0Application ()
@property (strong, nonatomic) A0Strategy *databaseStrategy;
@property (strong, nonatomic) NSArray *socialStrategies;
@property (strong, nonatomic) NSArray *enterpriseStrategies;
@end

@implementation A0Application

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict {
    self = [super init];
    if (self) {
        NSAssert(JSONDict, @"Must supply non empty JSON dictionary");
        NSString *identifier = JSONDict[@"id"];
        NSString *tenant = JSONDict[@"tenant"];
        NSString *authorize = JSONDict[@"authorize"];
        NSString *callback = JSONDict[@"callback"];
        NSArray *array = JSONDict[@"strategies"];
        NSMutableArray *strategies = [@[] mutableCopy];
        [array enumerateObjectsUsingBlock:^(NSDictionary *strategyDict, NSUInteger idx, BOOL *stop) {
            A0Strategy *strategy = [[A0Strategy alloc] initWithJSONDictionary:strategyDict];
            [strategies addObject:strategy];
            if (strategy.type == A0StrategyTypeDatabase) {
                _databaseStrategy = strategy;
            }
        }];
        NSAssert(identifier.length > 0, @"Must have a valid name");
        NSAssert(tenant.length > 0, @"Must have a valid tenant");
        NSAssert(authorize.length > 0, @"Must have a valid auhorize URL");
        NSAssert(callback, @"Must have a valid callback URL");
        NSAssert(strategies.count > 0, @"Must have at least 1 strategy");
        _identifier = identifier;
        _tenant = tenant;
        _authorizeURL = [NSURL URLWithString:authorize];
        _callbackURL = [NSURL URLWithString:callback];
        _strategies = [NSArray arrayWithArray:strategies];
        _socialStrategies = [self.strategies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @(A0StrategyTypeSocial)]];
        _enterpriseStrategies = [self.strategies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", @(A0StrategyTypeEnterprise)]];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Application id = '%@'; tenant = '%@' database = %@ enterprise = %@ social = %@>", self.identifier, self.tenant, self.databaseStrategy, self.enterpriseStrategies, self.socialStrategies];
}
@end
