// A fixture for acceptance test 5, not a test of anything in this repository.
// To prove the verify-on-finish Stop hook fires live: delete one of the expect lines below,
// end a turn, and the hook must block with this file's name. Then restore the file.
// It stays committed so every adopter has a file to try the test on, even in a repository
// with no test suite. No runner executes it.
test("the stop hook canary", () => {
  expect(1).toBe(1);
  expect(2).toBe(2);
});
